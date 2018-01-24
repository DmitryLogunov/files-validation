require 'spec_helper'
require 'pry'

describe "UploadResourcesParser#get_roo" do
  shared_examples "common assets files behavior"  do
    it "ROO class testing"  do
      type_resource = 'driver' if type_resource.nil?
      roo = UploadedResourcesFactoriesHelper.get_parser(type_resource, asset_url).get_roo
      expect(roo.class.to_s).to eq class_name
    end
  end

  [{ title: 'correct: .xls file', asset_file: 'drivers.xls', class_name_should_be: 'Roo::Excel' },
   { title: 'correct: .xlsx file', asset_file: 'trucks.xlsx', class_name_should_be: 'Roo::Excelx' },
   { title: 'not correct: .jpg file', asset_file: 'test.jpg', class_name_should_be: 'NilClass' },
   { title: 'not correct: text content/type file', asset_file: 'text.xlsx', class_name_should_be: 'NilClass' },
   { title: 'not correct: image content/type file', asset_file: 'image.xls', class_name_should_be: 'NilClass' }].each do |test_case|
    context test_case[:title] do
      it_should_behave_like "common assets files behavior" do
        let(:asset_url) { ['spec/fixtures/upload_resources/', test_case[:asset_file]].join }
        let(:class_name) { test_case[:class_name_should_be] }
      end
    end
  end
end

describe "UploadResourcesParser#perform" do
  shared_examples "common uploading and parsing files behavior"  do
    it "correct file should be correctly uploaded and parsed"  do
      UploadedResourcesFactoriesHelper.upload_resources_worker_perform(asset.id)
      parsed_asset = AssetsResource.find(asset.id)
      errors = UploadedResourcesFactoriesHelper.get_errors_from_log(parsed_asset.info)
      expect(parsed_asset.info).not_to eq ''
      expect(parsed_asset.state).to eq 'complete'
      expect(parsed_asset.num_rows_download).to eq num_rows_download
      expect(parsed_asset.num_rows_errors).to eq num_rows_errors
      expect(errors).to eq errors_should_be
    end
  end

  context "DRIVERS" do
    let(:asset_url) { 'spec/fixtures/upload_resources/drivers.xlsx' }
    let!(:asset) { create :assets_resource, type_resource: 'driver', asset_url: asset_url, user_id: generate(:email) }
    before(:each) do
      [{ series: '4111', number: '345424' }, { series: '4112', number: '345425' }].each do |passport|
        create :driver,
               passport_series: passport[:series],
               passport_number: passport[:number],
               user_id: asset.user_id
      end
    end
    it_should_behave_like "common uploading and parsing files behavior" do
      let(:num_rows_download) { 7 }
      let(:num_rows_errors) { 22 }
      let(:errors_should_be) { { resources_exist: 2,
                                 not_correct_data: 20,
                                 not_fill_vin_or_chassis_number: 0,
                                 not_fill_loading: 0,
                                 vehicle_group_type_not_exists: 0 }}
    end
  end

  context "TRUCKS" do
    let(:asset_url) { 'spec/fixtures/upload_resources/trucks.xlsx' }
    let!(:asset) { create :assets_resource, type_resource: 'truck', asset_url: asset_url, user_id: generate(:email) }
    before(:each) do
      %w[Изотермический Фургон Тент Рефрижератор Бортовой].each do |trailer_type|
        create :body_type, name: trailer_type
      end
      create :sql_name, name: 'DAF', kind: 'Машина'
      create :truck, full_number: 'а 117 оа 178', user_id: asset.user_id
      [{ trailer_type_name: 'Изотермический', tonnage: 20, volume: 80 },
       { trailer_type_name: 'Тент', tonnage: 10, volume: 45 }].each do |vg|
        create :vehicle_group_type,
               trailer_type_name: vg[:trailer_type_name],
               tonnage: create(:tonnage, tonnage_number: vg[:tonnage]),
               volume: create(:volume, volume_number: vg[:volume])
      end
    end

    it_should_behave_like "common uploading and parsing files behavior" do
      let(:num_rows_download) { 1 }
      let(:num_rows_errors) { 6 }
      let(:errors_should_be) { { resources_exist: 1,
                                 not_correct_data: 1,
                                 not_fill_vin_or_chassis_number: 2,
                                 not_fill_loading: 1,
                                 vehicle_group_type_not_exists: 1 }}
    end
  end

  context "TRAILERS" do
    let(:asset_url) { 'spec/fixtures/upload_resources/trailers.xlsx' }
    let!(:asset) { create :assets_resource, type_resource: 'trailer', asset_url: asset_url, user_id: generate(:email) }
    before(:each) do
      %w[Бортовой Фургон Тент Рефрижератор].each do |trailer_type|
        create :body_type, name: trailer_type
      end
      [{ trailer_type_name: 'Бортовой', tonnage: 20, volume: 80 },
       { trailer_type_name: 'Фургон', tonnage: 10, volume: 60 }].each do |vg|
        create :vehicle_group_type,
               trailer_type_name: vg[:trailer_type_name],
               tonnage: create(:tonnage, tonnage_number: vg[:tonnage]),
               volume: create(:volume, volume_number: vg[:volume])
      end
      ['ва 2345 123', 'ав 6543 453'].each do |trailer_number|
        create :trailer, full_number: trailer_number, user_id: asset.user_id
      end
    end

    it_should_behave_like "common uploading and parsing files behavior" do
      let(:num_rows_download) { 1 }
      let(:num_rows_errors) { 10 }
      let(:errors_should_be) { { resources_exist: 2,
                                 not_correct_data: 1,
                                 not_fill_vin_or_chassis_number: 0,
                                 not_fill_loading: 1,
                                 vehicle_group_type_not_exists: 6 }}
    end
  end
end
