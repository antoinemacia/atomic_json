FactoryBot.define do
  factory :order do
    data {
      {
        string_field: 'Salut',
        int_field: 1,
        array_field: [1, 3, 'string'],
        boolean_field: true,
        null_field: nil,
        timestamp: '',
        nested_field: {
          nested_one: "I'm nested"
        }
      }
    }
  end
end
