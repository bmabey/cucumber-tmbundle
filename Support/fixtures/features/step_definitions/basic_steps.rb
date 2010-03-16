Given "Basic step (given)" do
  Foo.should_not_error
end

Given "another basic step" do # a comment
  
end

Given %r{Basic regexp (.*) with multiple (.*) groups} do |first, second|
  
end

Given %r{Some quoted regexp "(.*)" and '(.*)'} do |first, second| # a comment
  
end

Given /classic regexp/ do # a comment
  
end

When "Basic when" do
  
end

Then 'Basic then' do
  
end
