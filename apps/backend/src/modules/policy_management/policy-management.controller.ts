import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { CreatePolicyManagementDto } from './dto/create-policy-management.dto';
import { UpdatePolicyManagementDto } from './dto/update-policy-management.dto';
import { PolicyManagementService } from './policy-management.service';

//TODO: Create a Basic CRUD Feature which only the Company Admin (COMPANYADMIN), which is basically the Insurance Company that will use this app, can access it, while the insurance agent can only view it.
//TODO: If we are done with the "Happy Path", proceed to writing unit tests to identify possible edge cases.
@Controller('policy-managements')
export class PolicyManagementController {
  constructor(
    private readonly policyManagementService: PolicyManagementService,
  ) {}

  @Post()
  create(@Body() createPolicyManagementDto: CreatePolicyManagementDto) {
    return this.policyManagementService.create(createPolicyManagementDto);
  }

  @Get()
  findAll(@Query('companyId') companyId: string) {
    return this.policyManagementService.findAll(companyId);
  }

  @Get(':productId')
  findOne(@Param('productId') id: string) {
    return this.policyManagementService.findOne(id);
  }

  @Patch(':productId')
  update(
    @Param('productId') productId: string,
    @Body() updatePolicyManagementDto: UpdatePolicyManagementDto,
  ) {
    return this.policyManagementService.update(
      productId,
      updatePolicyManagementDto,
    );
  }

  @Delete(':productId')
  remove(@Param('productId') id: string) {
    return this.policyManagementService.remove(id);
  }
}
