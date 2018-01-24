module UploadResourcesValidator
  module_function

  def validate(attribute, value, type_resource)
    # формат валидатора - массив [тип данных, [группы символов...], доп. параметры...]
    # типы данных:
    #   string - строка
    #   date - дата
    #   phone - телефон
    #   vin - формат VIN номера, регулярка: /^[[^IOQioq_]&&\w]{17}$/ , todo: надо добавить к исключениям !"№;%:?*()_+/|\=;:'"><{}[]@
    #   enum - перечисление
    #   tonnage_volume  - формат тоннаж / объем
    # группы символов типа string:
    #   ru - русские символы (строчные и прописные)
    #   en - латинские символы (строчные и прописные)
    #   spaces - пробел, дефиc
    #   quotes - кавычки
    #   number - знак №
    #   punctuation - точки и запятая
    #   slash - слэш (/)
    # доп. параметры (v1 , v2) :
    #  - для строки: v1 = мин. длина, v2 = макс. длина  (0 - поле не обязательное)
    #  - для даты: мин. допуcтимый год = текущий год - v1, макс. допустимый год = текущий год - v2
    validator = attributes(type_resource)[attribute][:validator]
    type_data = validator.first
    v1 = validator.third  # min длина, если 0 - поле не обязательное
    v2 = validator.fourth  # max длина (может быть не указана)
    case type_data
    when 'string'
      re = ""
      validator.second.each do |group_simbols|
        case group_simbols
        when 'ru' then re << "А-Яа-я"
        when 'en'  then  re << "A-Za-z"
        when 'int'  then re << "0-9"
        when 'spaces' then re << "\\s\\-\\xE2\\x80\\x94"
        when 'quotes' then re << "\"\'"
        when 'number' then re << "№"
        when 'punctuation' then re << "\\.\\,"
        when 'slash' then re << "\\/"
        end
      end
      re = "[#{re}]{#{v1},#{v2}}"
    when 'date'
      re = "(\\d{4})\\-((0{1}[1-9]{1})|((10|11|12){1}))\\-((0{1}[1-9]{1})|([12]{1}\\d{1})|([3]{1}[01]{1}))"
    when 'phone'
      re = "(7|8)?[0-9]{10}"
      value = value.to_s.gsub(/([\(\)\s\-\+])|(\.0)/, "")
    when 'vin'
      re = "[[^IOQioq_]&&\\w]{17}"
    when 'enum'
      re = ""
      if validator.second.is_a? Array
        re = validator.second.select(&:present?).join('|')
      end
      re = (re.blank? ? "(.){#{v1}}" : "(#{re}){#{v1},#{v2}}")
    when 'tonnage_volume'
      re = "[0-9]{1,2}(\\s){1,}?/(\\s){1,}?[0-9]{1,2}"
    end
    # если первый из параметров = 0, значит поле не обязательное (может быть не заполнено)
    re = "(#{re})?" if v1.to_i.zero?
    re = "^#{re}$"
    re = Regexp.compile(re)
    is_match = re.match(value).present?
    return is_match if type_data != 'date'
    return false unless is_match
    DateTime.parse(value).between? v1.years.ago, v2.years.ago
  end

  def additional_validations_requirements(errors_attributes, type_resource, resource)
    return errors_attributes if type_resource != 'truck'
    return errors_attributes if resource[:truck_type] != 'Седельный тягач'
    errors_attributes.delete_if { |e| [attributes(:truck)[:trailer_type][:ru],
                                       attributes(:truck)[:tonnage_volume][:ru]].include? e}
  end

  def check(dispatcher, type_resource, resource)
    case type_resource
    when :driver then check_driver(dispatcher, resource)
    when :truck then check_truck(dispatcher, resource)
    when :trailer then check_trailer(dispatcher, resource)
    end
  end

  def check_driver(dispatcher, resource)
    return { status: false, info: 'resource_exists' } if is_recource_exists?(dispatcher, :driver, resource)
    { status: true, info: 'success' }
  end

  def check_truck(dispatcher, resource)
    return { status: false, info: 'resource_exists' } if is_recource_exists?(dispatcher, :truck, resource)
    return { status: false, info: 'vehicle_group_type_not_exists' } if  resource[:truck_type] == 'Грузовой' && !is_vehicle_group_type_exists?(resource)
    return { status: false, info: 'not_fill_loading' } unless is_loading_filling?(resource)
    return { status: true, info: 'success' } if resource[:vin].present?
    return { status: false, info: 'not_fill_vin_or_engine_body_chassis_number' } if resource[:engine_number].blank?
    return { status: false, info: 'not_fill_vin_or_engine_body_chassis_number' } if resource[:body_number].blank? && resource[:chassis_number].blank?
    { status: true, info: 'success' }
  end

  def check_trailer(dispatcher, resource)
    return { status: false, info: 'resource_exists' } if is_recource_exists?(dispatcher, :trailer, resource)
    return { status: false, info: 'not_fill_loading' } unless is_loading_filling?(resource)
    return { status: false, info: 'not_fill_vin_or_chassis_number' } if resource[:vin].blank? && resource[:chassis_number].blank?
    return { status: false, info: 'vehicle_group_type_not_exists' } unless is_vehicle_group_type_exists?(resource)
    { status: true, info: 'success' }
  end

  def attributes(type_resource)
    # формат поля:
    #  'Наименование поля (en)' =>
    #      { validator: [...],
    #        ru: 'Название поля на кириллице'
    #        valid_params: [..параметры для получения валидного значения (используется в фабриках спеках)..]
    #      }
    # формат валидатора (validator):
    # [тип данных, [группы символов...], доп. параметры ...] (см. подробнее validate())
    case type_resource
    when :driver
      {
        last_name: { validator: ['string', ['ru'], 1, 150], ru: 'Фамилия', valid_params: [12, 'first_upcase'] },
        first_name: { validator: ['string', ['ru'], 1, 150], ru: 'Имя', valid_params: [12, 'first_upcase'] },
        middle_name: { validator: ['string', ['ru'], 0, 150], ru: 'Отчество', valid_params: [12, 'first_upcase'] },
        birthday: { validator: ['date', [], 100, 18], ru: 'День рождения', valid_params: [DateTime.now.year - 18, 50] },
        passport_series: { validator: ['string', ['int'], 4, 4], ru: 'ПаспортРФ. Cерия', valid_params: [4] },
        passport_number: { validator: ['string', ['int'], 6, 6], ru: 'ПаспортРФ. Номер', valid_params: [6] },
        passport_issued_by: { validator: ['string', %w[ru int spaces quotes number punctuation slash], 1, 255], ru: 'ПаспортРФ. Кем выдан', valid_params: [100, 'first_upcase', 5] },
        passport_issued_when: { validator: ['date', [], 100, 0], ru: 'ПаспортРФ. Когда выдан', valid_params: [DateTime.now.year - 1, 8] },
        address_region: { validator: ['string', %w[ru int spaces punctuation], 0, 100], ru: 'Область', valid_params: [100, 'first_upcase'] },
        address_zone: { validator: ['string', %w[ru int spaces punctuation], 0, 100], ru: 'Район', valid_params: [100, 'first_upcase'] },
        address_city: { validator: ['string', %w[ru int spaces punctuation], 1, 100], ru: 'Город', valid_params: [100, 'first_upcase'] },
        address_street: { validator: ['string', %w[ru int spaces punctuation], 1, 150], ru: 'Улица', valid_params: [100, 'first_upcase'] },
        address_house: { validator: ['string', ['int'], 1, 4], ru: 'Дом', valid_params: [2] },
        address_housing: { validator: ['string', %w[ru int spaces slash punctuation], 0, 6], ru: 'Корпус', valid_params: [1] },
        address_building: { validator: ['string', %w[ru int spaces slash punctuation], 0, 6], ru: 'Строение', valid_params: [1] },
        address_apartment: { validator: ['string', %w[ru int spaces punctuation], 0, 6], ru: 'Кварира/офис', valid_params: [3] },
        driver_license_number: { validator: ['string', %w[ru en int spaces punctuation], 1, 20], ru: 'Водительское удостоверение. Номер', valid_params: [10, 'any_downcase', 3] },
        driver_license_issued_by: { validator: ['string', %w[ru int spaces quotes number punctuation slash], 1, 255], ru: 'Водительское удостоверение. Кем выдано', valid_params: [100, 'first_upcase', 5] },
        driver_license_issued_when: { validator: ['date', [], 10, 0], ru: 'Водительское удостоверение. Когда выдано', valid_params: [DateTime.now.year - 1, 8] },
        phone1: { validator: ['phone', [], 0, 22], ru: 'Основной телефон', valid_params: [50] },
        phone2: { validator: ['phone', [], 0, 22], ru: 'Телефон 1', valid_params: [50] },
        phone3: { validator: ['phone', [], 0, 22], ru: 'Телефон 2', valid_params: [50] },
      }
    when :truck
      {
        truck_name: { validator: ['enum', trucks_names, 1, 1], ru: 'Марка', valid_params: trucks_names },
        truck_type: { validator: ['enum', trucks_types, 1, 1], ru: 'Тип автомашины', valid_params: trucks_types },
        trailer_type: { validator: ['enum', trailers_types, 1, 1], ru: 'Тип прицепа', valid_params: trailers_types },
        tonnage_volume: { validator: ['tonnage_volume', [], 1], ru: 'Тоннаж', valid_params: [10] },
        back_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Задняя', valid_params: %w[да нет] },
        side_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Боковая', valid_params: %w[да нет] },
        top_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Верхняя', valid_params: %w[да нет] },
        vrc_number: { validator: ['string', %w[ru en int number spaces], 1, 14], ru: 'Номер по СТС', valid_params: [10, '', 2] },
        vrc_owner: { validator: ['string', %w[ru en int spaces quotes number punctuation], 1, 150], ru: 'Владелей по СТС', valid_params: [35, 'first_upcase', 2] },
        license_plate_series_1: { validator: ['enum', license_plate_series_chars, 1, 1], ru: 'Госномер. Серия 1', valid_params: license_plate_series_chars },
        license_plate_number: { validator: ['string', ['int'], 2, 3], ru: 'Госномер. Номер', valid_params: [3] },
        license_plate_series_2: { validator: ['enum', license_plate_series_chars, 1, 2], ru: 'Госномер. Серия 2', valid_params: license_plate_series_chars },
        license_plate_region: { validator: ['string', ['int'], 2, 3], ru: 'Госномер. Регион', valid_params: [3] },
        vin: { validator: ['vin', 1], ru: 'VIN', valid_params: [17] },
        engine_number: { validator: ['string', %w[ru en int spaces punctuation slash], 0, 50], ru: 'Номер двигателя', valid_params: [50, 3] },
        body_number: { validator: ['string', %w[ru en int spaces slash], 0, 50], ru: 'Номер кузова', valid_params: [50, 3] },
        chassis_number: { validator: ['string', %w[ru en int spaces slash], 0, 50], ru: 'Номер шасси', valid_params: [50, 3] },
        phone: { validator: ['phone', [], 0, 22], ru: 'Номер телефона на машине', valid_params: [50] }
      }
    when :trailer
      {
        trailer_name: { validator: ['string', %w[ru en int spaces], 1, 50], ru: 'Марка', valid_params: [50, 3] },
        license_plate_series: { validator: ['enum', license_plate_series_chars, 1, 2], ru: 'Госномер. Серия', valid_params: license_plate_series_chars },
        license_plate_number: { validator: ['string', ['int'], 4, 4], ru: 'Госномер. Номер', valid_params: [4] },
        license_plate_region: { validator: ['string', ['int'], 1, 3], ru: 'Госномер. Регион', valid_params: [3] },
        vin: { validator: ['vin', [], 0, 1], ru: 'VIN', valid_params: [17] },
        chassis_number: { validator: ['string', %w[ru en int spaces punctuation slash], 0, 50], ru: 'Номер шасси', valid_params: [50, 3] },
        trailer_type: { validator: ['enum', trailers_types, 1, 1], ru: 'Тип прицепа', valid_params: trailers_types },
        tonnage_volume: { validator: ['tonnage_volume', [], 1], ru: 'Тоннаж / объем', valid_params: [10] },
        back_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Задняя', valid_params: %w[да нет] },
        side_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Боковая', valid_params: %w[да нет] },
        top_loading: { validator: ['enum', %w[да нет], 0, 1], ru: 'Тип загрузки. Верхняя', valid_params: %w[да нет] }
      }
    end
  end

  def get_aliases
    {
      'birthDate' => :birthday,
      'passportSeries' => :passport_series,
      'passportNumber' => :passport_number,
      'passportGivenBy' => :passport_issued_by,
      'passportGivenDate' => :passport_issued_when,
      'licenseNumber' => :driver_license_number,
      'licenseGivenBy' => :driver_license_issued_by,
      'licenseGivenDate' => :driver_license_issued_when,
      'truckName' => :truck_name,
      'VRCnumber' => :vrc_number,
      'VRCowner' => :vrc_owner,
      'VIN' => :vin,
      'engineNumber' => :engine_number,
      'bodyNumber' => :body_number,
      'chassisNumber' => :chassis_number,
      'trailerName' => :trailer_name
    }
  end

  def have_alias?(attribute)
    get_aliases[attribute].present?
  end

  def alias(attribute)
    get_aliases[attribute]
  end

  def trailers_types
    %w[Тент Рефрижератор Изотермический Бортовой Фургон]
  end

  def translate_trailers_types(trailer_type)
    case trailer_type
    when 'Тент' then 'tent'
    when 'Рефрижератор' then 'fridge'
    when 'Изотермический' then 'izoterm'
    when 'Бортовой' then 'board'
    when 'Фургон' then 'van'
    end
  end

  def trucks_types
    ['Грузовой', 'Седельный тягач']
  end

  def trucks_names
    SqlName.trucks.pluck(:name)
  end

  def license_plate_series_chars
    %w[А В Е К М Н О Р С Т У Х а в е к м н о р с т у х]
  end

  def is_vehicle_group_type_exists?(resource)
    trailer_type = resource[:trailer_type]
    tonnage_volume = resource[:tonnage_volume]
    return false if tonnage_volume.blank?
    tonnage, volume = tonnage_volume.split(' / ')
    VehicleGroupType.is_exists?(trailer_type, tonnage, volume)
  end

  def is_recource_exists?(dispatcher, type_resource, resource)
    case type_resource
    when :driver
      Driver
        .where(userID: dispatcher,
               passportSeries: resource[:passport_series],
               passportNumber: resource[:passport_number])
        .exists?
    when :truck
      truck_full_number = unique_identifer(resource, type_resource)
      Truck
        .where(userID: dispatcher,
               truckFullNumber: truck_full_number)
        .exists?
    when :trailer
      trailer_full_number = unique_identifer(resource, type_resource)
      Trailer
        .where(userID: dispatcher,
               trailerFullNumber: trailer_full_number)
        .exists?
    end
  end

  def is_loading_filling?(resource)
    return true if loading_to_bool(resource[:back_loading])
    return true if loading_to_bool(resource[:side_loading])
    return true if loading_to_bool(resource[:top_loading])
    false
  end

  def loading_to_bool(value)
    return true if value == true
    return true if value == 'да'
    false
  end

  def truck_type_to_bool(value)
    return true if value == true
    return true if value == 'Седельный тягач'
    false
  end

  def unique_identifer(resource, type_resource)
    parts_unique_identifer =
      case type_resource
      when :driver
        [:passport_series, :passport_number]
      when :truck
        [:license_plate_series_1, :license_plate_number, :license_plate_series_2, :license_plate_region]
      when :trailer
        [:license_plate_series, :license_plate_number, :license_plate_region]
      end
    parts_unique_identifer.map { |part| resource[part] }
                          .select(&:present?)
                          .join(' ')
  end
end
