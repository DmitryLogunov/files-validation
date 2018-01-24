require File.expand_path("../../", __FILE__) + '/upload_resources/validator.rb'
require 'roo'
require 'roo-xls'
require 'pry'

class UploadResourcesParser
  attr_accessor :asset, :columns, :roo, :result_parsing, :resource

  include UploadResourcesValidator

  def initialize(asset)
    @asset = asset
    @columns = UploadResourcesValidator.attributes(@asset.type_resource.to_sym)
    @roo = get_roo
    @result_parsing = { success: [], errors: [] }
    @resource = {}
  end

  def parse
    # При попытке здесь использовать @roo.present? выдается ошибка: ArgumentError: wrong number...
    if !@roo.nil?
      @roo.default_sheet = @roo.sheets.first
      3.upto(@roo.last_row) do |line|
        row = @roo.row(line)
        break if row.first.blank?
        errors_attributes = []
        @columns.each_with_index do |(key, validation_options), index|
          # формат validation_options(см.  UploadResourcesValidator.attributes()):
          attribute = key
          validator = validation_options[:validator]
          attribute_rus = validation_options[:ru]
          value = row[index].to_s.gsub(/\.0/, "")
          @resource.store(attribute, value)
          err = !UploadResourcesValidator.validate(attribute, value, @asset.type_resource.to_sym)
          errors_attributes << attribute_rus if err
        end
        # доп. требование ТЗ  - логически связаные валидации аттрибутов (пример: ТЗ п. 3.1.3 С,D)
        errors_attributes = UploadResourcesValidator.additional_validations_requirements(errors_attributes, @asset.type_resource, @resource)
        if errors_attributes.empty?
          err = UploadResourcesValidator.check(@asset.user_id, @asset.type_resource.to_sym, @resource)
          if err[:status]
            save
            @result_parsing[:success] << short_name
          else
            @result_parsing[:errors] << { name: short_name, status: 'not_allowed_to_save', info: err[:info] }
          end
        else
          @result_parsing[:errors] << { name: short_name, status: 'not_validate', info: errors_attributes }
        end
      end
      success_rows = @result_parsing[:success].length
      errors_rows = @result_parsing[:errors].length
      log = get_log.to_json
    else
      success_rows = 0
      errors_rows = 0
      log = 'Error file reading'
    end
    @asset.update!(num_rows_download: success_rows,
                   num_rows_errors: errors_rows,
                   info: log)
    { file: @asset.asset_url,
      type_resource: @asset.type_resource,
      all_rows: success_rows + errors_rows,
      num_rows_download: success_rows,
      num_rows_errors: errors_rows,
      info: log }
  end

  def save
    model =
      case @asset.type_resource
      when 'driver' then Driver
      when 'truck' then Truck
      when 'trailer' then Trailer
      end
    attributes = model.attributes_builder.types.keys
    data_save = {}
    attributes.each do |attribute|
      data_save.store(attribute, format_to_save(attribute))
    end

    resource = model.new(data_save)
    resource.save!
  end

  def format_to_save(attribute)
    return @resource[UploadResourcesValidator.alias(attribute)] if UploadResourcesValidator.have_alias?(attribute)

    case attribute
    when 'userID' then @asset.user_id
    when 'addedOn' then  DateTime.current.strftime('%Y-%m-%d')
    when 'name'
      [:last_name, :first_name, :middle_name].map { |part| @resource[part] }.select(&:present?).join(' ')
    when 'address'
      formatted_building = (@resource[:address_building].blank? && @resource[:address_building] != '-') ? " строение #{@resource[:address_building]}" : ""
      formatted_housing = (@resource[:address_housing].blank? && @resource[:address_housing] != '-') ? " корпус #{@resource[:address_housing]}" : ""
      formatted_house = (@resource[:address_house].blank? && @resource[:address_house] != '-') ? "дом №#{@resource[:address_house]}#{formatted_housing}#{formatted_building}" : ""
      formatted_apartment = (@resource[:address_apartment].blank? && resource[:address_apartment] != '-') ? "кв./офис #{@resource[:address_apartment]}" : ""
      [@resource[:address_region], @resource[:address_zone], @resource[:address_city], @resource[:address_street],
       formatted_house, formatted_apartment].select(&:present?).join(', ')
    when 'phone', 'phone1', 'phone2', 'phone3'
      @resource[attribute.to_sym].to_s.gsub(/([\(\)\s\-\+])|(\.0)/, "")
    when 'checkState', 'allowState' then 0
    when 'addressID'
      region, zone, city, street, house, housing, building, apartment =
        [:address_region, :address_zone, :address_city,
         :address_street, :address_house, :address_housing,
         :address_building, :address_apartment].map { |a| @resource[a] }
      formatted_building = [housing, building].select(&:present?).join('/')
      Address.create('adRegion' => region, 'adZone' => zone, 'adCity' => city, 'adStreet' => street,
                     'adHouse' => house, 'adBuilding' => formatted_building, 'adApartment' => apartment)
             .address_id
    when 'numDaysResoursesBlock' then 0
    when 'kkRaceNumDaysResourcesBlock' then 0
    when 'truckFullNumber' then UploadResourcesValidator.unique_identifer(@resource, :truck)
    when 'trailerFullNumber' then UploadResourcesValidator.unique_identifer(@resource, :trailer)
    when 'trailerType' then  UploadResourcesValidator.translate_trailers_types(@resource[:trailer_type])
    when 'mustHaveTrailer' then UploadResourcesValidator.truck_type_to_bool(@resource[:truck_type])
    when 'vehicleGroupUID'
      trailer_type = @resource[:trailer_type]
      tonnage, volume = @resource[:tonnage_volume].split(' / ')
      VehicleGroupType.get_uid(trailer_type, tonnage, volume)
    when 'topLoading' then UploadResourcesValidator.loading_to_bool(@resource[:top_loading])
    when 'sideLoading' then UploadResourcesValidator.loading_to_bool(@resource[:side_loading])
    when 'backLoading' then UploadResourcesValidator.loading_to_bool(@resource[:back_loading])
    when 'passportType' then 'Паспорт РФ'
    else ''
    end
  end

  def get_roo
    case type_file(@asset.asset_url)
    when 'xls' then Roo::Excel.new(@asset.asset_url)
    when 'xlsx' then Roo::Excelx.new(@asset.asset_url)
    end
  rescue
    nil
  end

  def type_file(file_url)
    file_url.split(".").last
  end

  def short_name
    attributes_for_short_form =
      case @asset.type_resource
      when 'driver'
        ['name']
      when 'truck'
        %w[truckName truckFullNumber]
      when 'trailer'
        %w[trailerName trailerFullNumber]
      end
    attributes_for_short_form.map! { |attribute| format_to_save(attribute) }
                             .select(&:present?)
                             .join(' ')
  end

  def get_log
    { success: @result_parsing[:success].select(&:present?).join(':'),
      not_correct_data: log_not_correct_data,
      resources_exist: @result_parsing[:errors].map { |e| e[:name] if e[:info] == "resource_exists" }
                                              .select(&:present?).join(':') }
  end

  # TODO: give correct name
  def log_not_correct_data_process_p(p)
    res = if p.second.kind_of?(Array)
            [p.first, p.second.join(', ')]
          elsif p.second == "not_fill_vin_or_engine_body_chassis_number"
            [p.first, ['При отсутствии VIN необходим номер двигателя и либо номер шосси, либо номер кузова']]
          elsif p.second == "not_fill_loading"
            [p.first, ['Не заполнен хотя бы один из видов загрузки']]
          elsif p.second == "vehicle_group_type_not_exists"
            [p.first, ['Не найдена группа ТС']]
          end
    res.join('_')
  end

  def log_not_correct_data
    @result_parsing[:errors]
      .map { |e| [e[:name], e[:info]] if e[:info].to_s != "resource_exists" }
      .select(&:present?)
      .map { |p| log_not_correct_data_process_p p }
      .join(':')
  end
end
