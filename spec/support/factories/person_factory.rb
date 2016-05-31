FactoryGirl.define do
  factory :person do
    first_name 'Jane'
    last_name 'Doe'

    factory :lendee do
      first_name 'Jack'
      last_name 'The Reader'
      books { create(:author_of_books).books }
    end
  end
end