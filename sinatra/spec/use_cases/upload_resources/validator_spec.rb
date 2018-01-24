require 'spec_helper'

describe "UploadResourcesValidator#validate" do
  shared_examples "'any uploaded resorce validation'" do
    it "valid resource should be valid" do
      errors = UploadedResourcesFactoriesHelper.is_valid?(valid, type_resource, :valid)
      expect(errors).to be_empty
    end

    it "not valid resource should be not valid" do
      errors = UploadedResourcesFactoriesHelper.is_valid?(not_valid, type_resource, :not_valid)
      expect(errors).to be_empty
    end

    it "should be not valid resource with empty required fields" do
      errors = UploadedResourcesFactoriesHelper.is_required_valid?(required_empty, type_resource)
      expect(errors).to be_empty
    end
  end

  context "test DRIVER" do
    it_should_behave_like "'any uploaded resorce validation'" do
      let(:type_resource) { :driver }
      let(:valid) { UploadedResourcesFactoriesHelper.valid :driver }
      let(:not_valid) { UploadedResourcesFactoriesHelper.not_valid :driver }
      let(:required_empty) { UploadedResourcesFactoriesHelper.required_empty :driver }
    end
  end

  context "test TRUCK" do
    before(:each) do
      10.times do
        create :body_type, name: UploadedResourcesFactoriesHelper.valid_value([:ru, :en], [10, :first_upcase])
      end
      create :sql_name, name: 'DAF', kind: 'Машина'
    end
    it_should_behave_like "'any uploaded resorce validation'" do
      let(:type_resource) { :truck }
      let(:valid) { UploadedResourcesFactoriesHelper.valid :truck }
      let(:not_valid) { UploadedResourcesFactoriesHelper.not_valid :truck }
      let(:required_empty) { UploadedResourcesFactoriesHelper.required_empty :truck }
    end
  end

  context "test TRAILER" do
    before(:each) do
      10.times do
        create :body_type, name: UploadedResourcesFactoriesHelper.valid_value([:ru, :en], [10, :first_upcase])
      end
    end
    it_should_behave_like "'any uploaded resorce validation'" do
      let(:type_resource) { :trailer }
      let(:valid) { UploadedResourcesFactoriesHelper.valid :trailer }
      let(:not_valid) { UploadedResourcesFactoriesHelper.not_valid :trailer }
      let(:required_empty) { UploadedResourcesFactoriesHelper.required_empty :trailer }
    end
  end
end

describe "UploadResourcesValidator#check" do
  shared_examples "'testing uploaded resorce exists'" do
    it "resource should not be able to save if exists" do
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(false)
      expect(errors[:info]).to eq('resource_exists')
    end
  end

  shared_examples "'check loading for trucks and trailers'" do
    it "resource should not be able to save if all types loading are empty despite filling 'vin'" do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check type_resource, [:vin]
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(false)
      expect(errors[:info]).to eq('not_fill_loading')
    end

    it "resource should be able to save if all types loading are empty unless 'back_loading' and 'vin'" do
      filled_attributes = [:back_loading, :vin]
      filled_attributes << :trailer_type << :tonnage_volume if [:trailer, :truck].include?(type_resource)
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, filled_attributes)
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should be able to save if all types loading are empty unless 'side_loading' and 'vin'" do
      filled_attributes = [:side_loading, :vin]
      filled_attributes << :trailer_type << :tonnage_volume if [:trailer, :truck].include?(type_resource)
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, filled_attributes)
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should be able to save if all types loading are empty unless 'top_loading' and 'vin'" do
      filled_attributes = [:top_loading, :vin]
      filled_attributes << :trailer_type << :tonnage_volume if [:trailer, :truck].include?(type_resource)
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, filled_attributes)
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should not be able to save if 'vehicle_group_type' not exists" do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :vin])
      resource_to_check[:truck_type] = 'Грузовой' if type_resource == :truck
      trailer_type, tonnage_volume = UploadedResourcesFactoriesHelper.get_not_exists_params_vehicle_group
      resource_to_check[:trailer_type] = trailer_type
      resource_to_check[:tonnage_volume] = tonnage_volume
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(false)
      expect(errors[:info]).to eq('vehicle_group_type_not_exists')
    end
  end

  context "test DRIVER" do
    it_should_behave_like "'testing uploaded resorce exists'" do
      let(:resource_to_check) { { last_name: 'Тестов', first_name: 'Тест', middle_name: 'Тестович', passport_series: '4087', passport_number: '123456', driver_license_number: '3123123' } }
      let(:type_resource) { :driver }
      let(:dispatcher) { 'test@dispatcher' }
      before do
        create :driver, userID: dispatcher,
                        passportSeries: resource_to_check[:passport_series],
                        passportNumber: resource_to_check[:passport_number]
      end
    end
  end

  context "test TRUCK" do
    it_should_behave_like "'testing uploaded resorce exists'" do
      let(:resource_to_check) { { truck_name: 'MAN', license_plate_series_1: 'А', license_plate_number: '123', license_plate_series_2: 'ВВ', license_plate_region: '432' } }
      let(:type_resource) { :truck }
      let(:dispatcher) { 'test@dispatcher' }
      before do
        create :truck, userID: dispatcher,
                       truckName: resource_to_check[:truck_name],
                       truckFullNumber: UploadResourcesValidator.unique_identifer(resource_to_check, :truck)
        create :vehicle_group_type
      end
    end

    it_should_behave_like "'check loading for trucks and trailers'" do
      let(:type_resource) { :truck }
      let(:dispatcher) { 'test@dispatcher' }
      before do
        create :vehicle_group_type
      end
    end

    let(:type_resource) { :truck }
    let(:dispatcher) { 'test@dispatcher' }

    before(:each) do
      create :vehicle_group_type
    end

    it "resource should not be able to save if 'vin', 'engine_number', 'body_number' and 'chassis_number' are empty " do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(false)
      expect(errors[:info]).to eq('not_fill_vin_or_engine_body_chassis_number')
    end

    it "resource should be able to save if 'engine_number', 'body_number' and 'chassis_number' are empty but 'vin' is filled " do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :vin])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should be able to save if 'vin', 'body_number' are empty but 'engine_number' and 'chassis_number' are filled " do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :engine_number, :chassis_number])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should be able to save if 'vin' and 'chassis_number' are empty but 'engine_number' and'body_number' are filled " do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :engine_number, :body_number])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end
  end

  context "test TRAILER" do
    it_should_behave_like "'testing uploaded resorce exists'" do
      let(:resource_to_check) { { trailer_name: 'Ackermann', license_plate_series: 'А', license_plate_number: '123', license_plate_region: '432' } }
      let(:type_resource) { :trailer }
      let(:dispatcher) { 'test@dispatcher' }
      before do
        create :trailer, userID: dispatcher,
                         trailerName: resource_to_check[:trailer_name],
                         trailerFullNumber: UploadResourcesValidator.unique_identifer(resource_to_check, :trailer)
      end
    end
    it_should_behave_like "'check loading for trucks and trailers'" do
      let(:type_resource) { :trailer }
      let(:dispatcher) { 'test@dispatcher' }
      before do
        create :vehicle_group_type
      end
    end

    let(:type_resource) { :trailer }
    let(:dispatcher) { 'test@dispatcher' }

    it "resource should not be able to save if 'vin' and 'chassis_number' are empty " do
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(false)
      expect(errors[:info]).to eq('not_fill_vin_or_chassis_number')
    end

    it "resource should be able to save if 'chassis_number' is empty but 'vin' is filled " do
      create :vehicle_group_type
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :vin, :trailer_type, :tonnage_volume])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end

    it "resource should be able to save if 'vin' is empty but 'chassis_number' is filled " do
      create :vehicle_group_type
      resource_to_check = UploadedResourcesFactoriesHelper.transport_resource_to_check(type_resource, [:back_loading, :chassis_number, :trailer_type, :tonnage_volume])
      errors = UploadResourcesValidator.check(dispatcher, type_resource, resource_to_check)
      expect(errors[:status]).to eq(true)
      expect(errors[:info]).to eq('success')
    end
  end
end
