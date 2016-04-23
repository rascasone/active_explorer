FactoryGirl.define do
  factory :book do
    title 'The Warded Man'
    year 2008

    factory :book_with_review do
      reviews { [create(:review)] }
    end
  end
end