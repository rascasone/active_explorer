FactoryGirl.define do
  factory :author do
    first_name 'Perer'
    last_name 'Brett'
    books { [create(:book), create(:book, title: 'The Desert Spear', year: 2010)] }
  end
end