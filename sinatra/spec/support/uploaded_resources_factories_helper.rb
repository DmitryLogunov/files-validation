require 'pry'

module UploadedResourcesFactoriesHelper
  # вспомогательный модуль для генерации  валидных и невалидных
  # ресурсов (водителей, авто, прицепов)

  CHARS_EN = %w[A B C D E F G H I K L M N O P Q R S T V X Y Z].freeze
  CHARS_RU = %w[А Б В Г Д Е Ж З И Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я].freeze
  CHARS_RU_DOWNCASE = %w[а б в г д е ж з и й к л м н о р с т у ф х ц ч ш щ ь э ю я].freeze
  VIN = %w[A B C D E F G H K L M N P R S T V X Y Z].freeze
  INT = %w[0 1 2 3 4 5 6 7 8 9].freeze
  SLASH = %w[/].freeze
  PUNCTUATION = %w[. ,].freeze
  SPACES = %w[-].freeze
  QUOTES = %w[" " ' '].freeze
  NUMBER = %w[№].freeze
  WRONG_SIMBOLS = %w[% \ _ ! @ # ? & ^ * | [ ] { } ~ `].freeze
  ROOT_PATH = File.expand_path("../../../", __FILE__)

  module_function

  def upload_resources_worker_perform(id)
    ActiveRecord::Base.transaction do
      asset = AssetsResource.find(id)
      return if asset.complete?
      asset.to_process
      log = UploadResourcesParser.new(asset).parse
      asset.to_complete!
    end
  end

  def valid(type_resource)
    # генерирует валидный ресурс (водитель, авто, прицеп)
    resource_valid_options = valid_options(type_resource)
    resource = {}
    resource_valid_options.each do |attribute, validator|
      valid_types, valid_params = validator
      resource.store(attribute, valid_value(valid_types, valid_params))
    end
    resource
  end

  def not_valid(type_resource)
    # генерирует невалидный ресурс (водитель, авто, прицеп) с невалидными полями
    standart_types = %w[date phone tonnage_volume enum vin]
    resource_valid_options = valid_options(type_resource)
    resource = {}
    resource_valid_options.each do |attribute, validator|
      valid_types, valid_params = validator
      not_valid_types =
        if valid_types.length == 1 && (standart_types.include? valid_types.first)
          %w[wrong_simbols]
        else
          %w[ru en int punctuation slash allowed_simbols wrong_simbols]
        end
      not_valid_types.delete_if { |type| valid_types.include? type }
      not_valid_value = valid_value(valid_types, valid_params).to_s << valid_value(not_valid_types, [1]).to_s
      resource.store(attribute, not_valid_value)
    end
    resource
  end

  # транспортный ресурс (авто или прицеп) для проверки возможности сохраниения функцией #check
  # оставляем непустыми только те аттрибуты, которые пеерчислены в attributes_correct
  def transport_resource_to_check(type_resource, attributes_correct)
    resource = valid(type_resource)
    if [:trailer, :truck].include?(type_resource)
      trailer_type, tonnage_volume = get_first_vehicle_group_type
      resource[:trailer_type] = trailer_type
      resource[:tonnage_volume] = tonnage_volume
    end
    return resource unless attributes_correct.present?
    [:back_loading, :side_loading, :top_loading, :vin, :engine_number,
     :body_number, :chassis_number].each do |checked_attribute|
      resource[checked_attribute] = '' unless  attributes_correct.include?(checked_attribute)
    end
    [:back_loading, :side_loading, :top_loading].each do |loading_attribute|
      resource[loading_attribute] = 'да' if attributes_correct.include?(loading_attribute)
    end
    resource
  end

  def required_empty(type_resource)
    # генерирует ресурс с незаполенными обязательными полями
    validation_masks = UploadResourcesValidator.attributes(type_resource)
    resource_valid_options = valid_options(type_resource)
    resource = {}
    resource_valid_options.each do |attribute, validator|
      is_attribute_required = validation_masks[attribute][:validator].third.to_i > 0
      valid_types, valid_params = validator
      value = is_attribute_required ? '' : valid_value(valid_types, valid_params)
      resource.store(attribute, value)
    end
    resource
  end

  def is_valid?(resource, type_resource, should_be)
    errors = {}
    should_be = should_be == :valid
    resource.each do |attribute, value|
      is_valid = UploadResourcesValidator.validate(attribute, value, type_resource)
      next unless is_valid != should_be
      errors.store(attribute, value: value,
                              is_valid: is_valid ? 'valid' : 'not_valid',
                              should_be: should_be ? 'valid' : 'not_valid')
    end
    errors
  end

  def is_required_valid?(resource, type_resource)
    errors = {}
    validation_masks = UploadResourcesValidator.attributes(type_resource)
    resource.each do |attribute, value|
      is_attribute_required = validation_masks[attribute][:validator].third.to_i > 0
      should_be = !(is_attribute_required && value.empty?)
      is_valid = UploadResourcesValidator.validate(attribute, value, type_resource)
      next unless is_valid != should_be
      errors.store(attribute,
                   is_required_valid: is_attribute_required ? 'required' : 'not_required',
                   value: value,
                   is_valid: is_valid ? 'valid' : 'not_valid',
                   should_be: should_be ? 'valid' : 'not_valid')
    end
    errors
  end

  def get_first_vehicle_group_type
    vehicle_group_type = VehicleGroupType.all.first
    vehicle_group_type_uid = vehicle_group_type.uid if vehicle_group_type.present?
    vehicle_group_type = []
    if vehicle_group_type_uid.present?
      trailer_type, tonnage, volume = VehicleGroupType.get_type_and_size_by_uid vehicle_group_type_uid
      tonnage_volume = [tonnage, volume].map { |x| x.to_s.gsub(/\.0/, "") }.join(' / ')
      vehicle_group_type = [trailer_type, tonnage_volume]
    end
    vehicle_group_type
  end

  def get_not_exists_params_vehicle_group
    trailer_type = ""
    tonnage_volume = ""
    loop  do
      trailer_type = valid_value ['en'], [35, 'all_downcase']
      tonnage_volume = "#{10 + rand(90)} / #{10 + rand(90)}"
      break unless UploadResourcesValidator.is_vehicle_group_type_exists?(trailer_type: trailer_type, tonnage_volume: tonnage_volume)
    end
    [trailer_type, tonnage_volume]
  end

  def valid_options(type_resource)
    validation_masks = UploadResourcesValidator.attributes(type_resource)
    attributes_valid_options = {}
    validation_masks.each do |attribute, mask|
      valid_types =
        if mask[:validator].first == 'string'
          mask[:validator].second
        else
          [mask[:validator].first]
        end
      valid_params = mask[:valid_params]
      attributes_valid_options.store(attribute, [valid_types, valid_params])
    end
    attributes_valid_options
  end

  def valid_value(valid_types, valid_params)
    standart_types = %w[date phone tonnage_volume enum]
    valid_string =
      if valid_types.length == 1 && standart_types.include?(valid_types.first)
        case valid_types.first
        when 'date' then valid_date(valid_params)
        when 'phone' then valid_phone
        when 'tonnage_volume' then  valid_value(['int'], [2]) + " / " + valid_value(['int'], [2])
        when 'enum' then valid_params[rand(valid_params.length)]
        end
      else
        num_simbols, which_case, num_spaces = valid_params
        source_simbols = get_source_simbols(valid_types)
        valid_string = []
        1.upto(num_simbols) { valid_string << source_simbols[rand(source_simbols.length)] }
        if num_spaces.present? && num_spaces.to_i > 0
          1.upto(num_spaces) { valid_string << " " }
          valid_string.sort_by! { rand }
        end
        valid_string.join
      end
    valid_string
  end

  def valid_date(valid_params)
    date_start = Date.parse((valid_params.first.to_i - valid_params.last.to_i).to_s + '-01-01')
    date_end = Date.parse("#{valid_params.first}-01-01")
    rand(date_start..date_end).strftime('%F')
  end

  def valid_phone
    case rand(10) % 4
    when 0
      "+7 " + valid_value(['int'], [3]) + " " + valid_value(['int'], [3])\
       +" " + valid_value(['int'], [2]) + " " + valid_value(['int'], [2])
    when 1
      "8 (" + valid_value(['int'], [3]) + ") " + valid_value(['int'], [3])\
       +"-" + valid_value(['int'], [2]) + "-" + valid_value(['int'], [2])
    when 2
      "+7 (" + valid_value(['int'], [3]) + ") " + valid_value(['int'], [4])\
       +" " + valid_value(['int'], [3])
    when 3
      "8" + valid_value(['int'], [10])
    end
  end

  def get_source_simbols(valid_types)
    source_simbols = []
    valid_types.each do |type|
      source_simbols += case type
                        when 'en' then CHARS_EN
                        when 'ru' then CHARS_RU
                        when 'punctuation' then PUNCTUATION
                        when 'slash' then SLASH
                        when 'spaces' then SPACES
                        when 'vin' then VIN + INT
                        when 'int' then INT
                        when 'quotes' then QUOTES
                        when 'number' then NUMBER
                        when 'wrong_simbols' then WRONG_SIMBOLS
                        else [type]
                        end
    end
    source_simbols
  end

  def get_errors_from_log(info)
    if info.blank?
      return { resources_exist: 0,
               not_correct_data: 0,
               not_fill_vin_or_chassis_number: 0,
               not_fill_loading: 0,
               vehicle_group_type_not_exists: 0 }
    end

    resources_exist = JSON.parse(info)["resources_exist"].split(':').length

    not_correct_data = JSON.parse(info)["not_correct_data"]
                           .split(':')
                           .map! { |p| p.split('_') }
    not_fill_vin_or_chassis_number =
      not_correct_data.map { |r| r.first if r.second == "При отсутствии VIN необходим номер двигателя и либо номер шосси, либо номер кузова" }
                      .select(&:present?)
                      .length
    not_fill_loading =
      not_correct_data.map { |r| r.first if r.second == "Не заполнен хотя бы один из видов загрузки" }
                      .select(&:present?)
                      .length
    vehicle_group_type_not_exists =
      not_correct_data.map { |r| r.first if r.second == "Не найдена группа ТС" }
                      .select(&:present?)
                      .length
    { resources_exist: resources_exist,
      not_correct_data: not_correct_data.length - not_fill_vin_or_chassis_number - not_fill_loading - vehicle_group_type_not_exists,
      not_fill_vin_or_chassis_number: not_fill_vin_or_chassis_number,
      not_fill_loading: not_fill_loading,
      vehicle_group_type_not_exists: vehicle_group_type_not_exists }
  end

  def get_parser(type_resource, asset_url)
    asset = FactoryBot.create :assets_resource, type_resource: type_resource, asset_url: [ROOT_PATH, '/', asset_url].join
    UploadResourcesParser.new asset
  end
end
