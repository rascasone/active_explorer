FactoryGirl.define do
  factory :review do
    stars 5
    text 'Very nice book. Life changing experience.'
    author { create(:author, first_name: 'Marek', last_name: 'Ulicny') }
  end
end