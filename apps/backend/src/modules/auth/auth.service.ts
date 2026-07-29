import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
import { MailService } from '../mail/mail.service';
import { join } from 'path';
import { existsSync } from 'fs';
import { AppConstants } from '../../common/constants/app.constants';
import { User } from '../../generated/client';
import { Prisma } from '../../generated/client';
@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private readonly mailService: MailService,
    private readonly appContstants: AppConstants,
  ) {}

  async agentRegister(
    firstName: string,
    middleName: string,
    lastName: string,
    insuranceCompanyId: string,
    birthDate: Date,
    email: string,
    password: string,
  ) {
    const templatePath = join(
      __dirname,
      '..',
      'mail',
      'templates',
      'registration-confirmation.ejs',
    );

    if (!existsSync(templatePath)) {
      throw new Error('Template File not found.');
    }

    const hashedPassword: string = await bcrypt.hash(
      password,
      this.appContstants.saltRounds,
    );
    const verificationToken: string = randomUUID();

    const isSuccess = await this.prisma.user.create({
      data: {
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        birthDate: birthDate,
        email: email,
        passwordHash: hashedPassword,
        verificationToken: verificationToken,
        verificationTokenExpiresAt: new Date().toISOString(),
      },
    });

    if (isSuccess !== null) {
      await this.prisma.insuranceAgent.create({
        data: {
          userId: isSuccess.id,
          insuranceCompanyId: insuranceCompanyId,
        },
      });

      await this.mailService.sendMail(
        email,
        'Welcome to the Insurance Agent Remittance Engine',
        templatePath,
        {
          firstName: firstName,
          lastName: lastName,
          confirmationLink: `${this.appContstants.backendLink}/auth/verify-token?verificationToken=${verificationToken}`,
        },
      );
      return { success: true };
    }

    return { success: false };
  }

  async validateUser(email: string, pass: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user)
      throw new UnauthorizedException(
        'Sorry. Your email does not exist. Please Try Again',
      );

    const verify = await bcrypt.compare(pass, user.passwordHash);

    if (!verify)
      throw new UnauthorizedException(
        'Your Password is incorrect. Please Try Again',
      );

    return user;
  }

  async login(user: {
    id: string;
    email: string;
    role: string;
    createdAt: Date;
    updatedAt: Date;
  }) {
    const tokens = await this.issueTokens(user.id, user.email, user.role);

    const agentProfileArgs =
      Prisma.validator<Prisma.InsuranceAgentDefaultArgs>()({
        include: {
          user: true,
          insuranceCompany: true,
        },
      });

    type AgentProfile = Prisma.InsuranceAgentGetPayload<
      typeof agentProfileArgs
    >;

    const userProfile: AgentProfile | null =
      await this.prisma.insuranceAgent.findUnique({
        where: { userId: user.id },
        ...agentProfileArgs,
      });

    if (!userProfile) {
      throw new NotFoundException(
        'Your Profile Does not exist in our platform.',
      );
    }

    const fullName = [
      userProfile.user.firstName,
      userProfile.user.middleName,
      userProfile.user.lastName,
    ]
      .filter(Boolean)
      .join(' ');

    const insuranceCompany = userProfile.insuranceCompany.companyName;
    const companyId = userProfile.insuranceCompany.id;

    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return {
      ...tokens,
      user: {
        id: user.id,
        companyId,
        fullName,
        insuranceCompany,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    };
  }

  async refresh(userId: string, refreshToken: string) {
    const activeTokens = await this.prisma.refreshToken.findMany({
      where: { userId, revokedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    let matchedTokenId: string | null = null;

    for (const rt of activeTokens) {
      if (await bcrypt.compare(refreshToken, rt.tokenHash)) {
        matchedTokenId = rt.id;
        break;
      }
    }

    if (!matchedTokenId)
      throw new UnauthorizedException(
        'This refresh token is invalid. Please login again.',
      );

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user)
      throw new UnauthorizedException(
        'Sorry. This user does not exist. Please login again.',
      );

    const tokens = await this.issueTokens(user.id, user.email, user.role);

    await this.prisma.$transaction([
      this.prisma.refreshToken.update({
        where: { id: matchedTokenId },
        data: { revokedAt: new Date() },
      }),
      this.prisma.refreshToken.create({
        data: {
          id: randomUUID(),
          userId,
          tokenHash: await bcrypt.hash(tokens.refreshToken, 12),
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
      }),
    ]);

    return tokens;
  }

  async logout(userId: string, refreshToken: string) {
    const tokens = await this.prisma.refreshToken.findMany({
      where: { userId, revokedAt: null },
    });

    for (const rt of tokens) {
      if (await bcrypt.compare(refreshToken, rt.tokenHash)) {
        await this.prisma.refreshToken.update({
          where: { id: rt.id },
          data: { revokedAt: new Date() },
        });
        break;
      }
    }

    return { success: true };
  }

  async verifyEmailToken(verificationToken: string) {
    const userVerify = await this.prisma.user.findFirst({
      where: { verificationToken },
    });

    if (!userVerify) {
      return {
        message: 'Sorry. This token is invalid. Please register again. ',
      };
    }
    const now: Date = new Date();

    await this.prisma.user.update({
      data: {
        verificationToken: null,
        emailConfirmedAt: now.toISOString(),
        verificationTokenExpiresAt: null,
      },
      where: { email: userVerify.email },
    });

    return {
      message:
        'You have successfully verified your email. You can now login to the app. Please click this link to be able to login: ',
    };
  }

  /**
   * This is only accessible to only this class. These two functions manage all user tokens when accessing the mobile app via API.
   */

  private async issueTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: process.env.JWT_ACCESS_SECRET,
        expiresIn: '15m',
      }),
      this.jwtService.signAsync(payload, {
        secret: process.env.JWT_REFRESH_SECRET,
        expiresIn: '7d',
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private async storeRefreshToken(userId: string, refreshToken: string) {
    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash: await bcrypt.hash(refreshToken, 12),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });
  }
}
