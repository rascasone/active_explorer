FactoryGirl.define do
  factory :author do
    first_name 'John'
    last_name 'Doe'

    factory :author_of_books do
      first_name 'Perer'
      last_name 'Brett'
      books { [create(:book_with_review), create(:book, title: 'The Desert Spear', year: 2010)] }
    end
  end
end