FactoryGirl.define do
  factory :task do
    title "MyString"
    description "MyText"
    done false
    deadline "2017-10-01 17:14:26"
    user nil
  end
end
