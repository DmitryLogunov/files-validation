module LoadingTypes
  ALL = %w[Задняя Боковая Верхняя].freeze

  BACK_BITS = 1 # 0001
  SIDE_BITS = 2 # 0010
  UP_BITS = 4   # 0100

  def loading_types
    loading_types = []
    loading_types << 'Задняя' if back_loading
    loading_types << 'Боковая' if side_loading
    loading_types << 'Верхняя' if top_loading
    loading_types
  end

  def loading_types=(vals)
    self.back_loading = vals.include?('Задняя')
    self.side_loading = vals.include?('Боковая')
    self.top_loading = vals.include?('Верхняя')
  end

  def normalized_loading_types_bits
    bits = 0
    # Задняя, по ТЗ https://twiki.dellin.ru/pages/viewpage.action?pageId=44055567 Задняя есть по умалчанию
    bits |= BACK_BITS if back_loading || side_loading || top_loading
    # Боковая
    bits |= SIDE_BITS if side_loading
    # Верхняя
    bits |= UP_BITS if top_loading
    bits
  end
end
