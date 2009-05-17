Given "Basic step (given)" do
  Foo.should_not_error
end

Given "another basic step" do
  
end

Given %r{Basic regexp (.*) with multiple (.*) groups} do |first, second|
  
end

Given %r{Some quoted regexp "(.*)" and '(.*)'} do |first, second|
  
end

Given /classic regexp/ do
  
end

When "Basic when" do
  
end

Then 'Basic then' do
  
end
