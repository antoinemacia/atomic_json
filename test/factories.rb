FactoryBot.define do
  factory :order do
    data do
      {
        string_field: 'Salut',
        int_field: 1,
        array_field: [1, 3, 'string'],
        boolean_field: true,
        null_field: 'Obviously not null',
        timestamp: '',
        json_field: nil,
        nested_field: {
          nested_one: {
            nested_two: nil,
            nested_three: 'hey',
            nested_four: 'yo'
          }
        }
      }
    end
  end
end
