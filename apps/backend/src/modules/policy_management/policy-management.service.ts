import { Injectable, NotFoundException } from '@nestjs/common';
import { CreatePolicyManagementDto } from './dto/create-policy-management.dto';
import { UpdatePolicyManagementDto } from './dto/update-policy-management.dto';
import { PrismaService } from '../../prisma/prisma.service';
import { AppConstants } from '../../common/constants/app.constants';

@Injectable()
export class PolicyManagementService {
  constructor(
    private prisma: PrismaService,
    private appConstants: AppConstants,
  ) {}
  //TODO: If we are done with the "Happy Path", proceed to writing unit tests to identify possible edge cases.
  async create(createPolicyManagementDto: CreatePolicyManagementDto) {
    const {
      insuranceProductName,
      productContents,
      productAmount,
      paymentTerms,
    } = createPolicyManagementDto;

    await this.prisma.insuranceProduct.create({
      data: {
        insuranceCompanyId: 'dedsadeffsdea',
        insuranceProductName: insuranceProductName,
        productContents: productContents,
        productAmount: productAmount,
        paymentTerms: paymentTerms,
      },
    });
  }

  async findAll(insuranceCompanyId: string) {
    const insuranceProducts = await this.prisma.insuranceProduct.findMany({
      where: {
        insuranceCompanyId: insuranceCompanyId,
      },
    });

    if (!insuranceProducts) return null;

    return insuranceProducts;
  }

  async findOne(id: string) {
    const insuranceProduct =
      await this.prisma.insuranceProduct.findFirstOrThrow({
        where: {
          id: id,
        },
      });

    if (!insuranceProduct)
      throw new NotFoundException(
        'Insurance details cannot be retrieved. Please Try Again.',
      );

    return insuranceProduct;
  }

  async update(
    id: string,
    updatePolicyManagementDto: UpdatePolicyManagementDto,
  ) {
    const {
      insuranceProductName,
      productContents,
      productAmount,
      paymentTerms,
    } = updatePolicyManagementDto;

    await this.prisma.insuranceProduct.update({
      data: {
        insuranceProductName: insuranceProductName,
        productContents: productContents,
        productAmount: productAmount,
        paymentTerms: paymentTerms,
      },
      where: {
        id: id,
        insuranceCompanyId: 'cedjschcbseydbseydb',
      },
    });
  }

  async remove(id: string) {
    const insuranceProduct = await this.prisma.insuranceProduct.delete({
      where: {
        id: id,
      },
    });

    if (!insuranceProduct)
      throw new NotFoundException(
        'Unable to Delete Insurance Product. Maybe it was deleted already.',
      );

    return 'Insurance Product Successfully deleted.';
  }
}
