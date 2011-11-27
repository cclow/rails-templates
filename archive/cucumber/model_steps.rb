Given /^there (is|are) (\d+) "([^\"]*)" records?$/ do |_, count, model|
  @records ||= {}
  @records[model] ||= []
  klass = model.underscore.to_sym
  count.to_i.times do |i|
    @records[model][i] = Factory(klass)
  end
end

# FIXME port over from mchinist to factory_girl
Given /^there (is|are) (\d+) "([^\"]*)" records of "([^\"]*)" (\d+) record$/ do |_, count, model, parent, ord|
  @records[model] ||= []
  aggregate = @records[parent][ord.to_i].send model.pluralize
  count.to_i.times do |i|
    @records[model][i] = aggregate.make
  end
end

When /^I fill in "([^\"]*)" with "([^\"]*)" value from "([^\"]*)" record$/ do |field, attr, model|
  steps %Q(When I fill in "#{field}" with "#{@records[model][0].send(attr)}")
end

When /^I fill in "([^\"]*)" with previous "([^\"]*)"$/ do |field, key|
  steps %Q(When I fill in "#{field}" with "#{@values[key]}")
end

When /^I fill in "([^\"]*)" with sham "([^\"]*)"$/ do |field, key|
  @values ||= {}
  @values[key] = Sham.send(key)
  steps %Q(When I fill in "#{field}" with "#{@values[key]}")
end

When /^I fill in "([^"]*)" with the same "([^"]*)"$/ do |field, key|
  steps %Q(When I fill in "#{field}" with "#{@values[key]}")
end

When /^I select "([^\"]*)" value of "([^\"]*)" record from "([^\"]*)"$/ do |attr, model, field|
  steps %Q(When I select "#{@records[model][0].send(attr)}" from "#{field}")
end

When /^I select "([^\"]*)" value of "([^\"]*)" (\d+) record from "([^\"]*)"$/ do |attr, model, ord, field|
  steps %Q(When I select "#{@records[model][ord.to_i].send(attr)}" from "#{field}")
end

When /^I fill in "([^\"]*)" with currency sham "([^\"]*)"$/ do |field, key|
  @values ||= {}
  @values[key] = Sham.send(key)
  steps %Q(When I fill in "#{field}" with "#{amount_to_currency @values[key]}")
end

When /^I select sham "([^\"]*)" as the "([^\"]*)" date$/ do |key, field|
  @values = {}
  @values[key] = Sham.send(key)
  steps %Q(When I select "#{@values[key]}" as the "#{field}" date)
end

Then /^I should see "([^\"]*)" value of "([^\"]*)" record$/ do |attr, model|
  steps %Q(Then I should see "#{@records[model][0].send(attr)}")
end

Then /^I should see "([^\"]*)" values of "([^\"]*)" records$/ do |attr, model|
  @records[model].each do |record|
    steps %Q(Then I should see "#{record.send(attr)}")
  end
end

Then /^I should see "([^\"]*)" date values of "([^\"]*)" records$/ do |attr, model|
  @records[model].each do |record|
    steps %Q(Then I should see "#{display_date record.send(attr)}")
  end
end

Then /^I should see "([^\"]*)" currency values of "([^\"]*)" records$/ do |attr, model|
  @records[model].each do |record|
    steps %Q(Then I should see "#{amount_to_currency record.send(attr)}")
  end
end

Then /^I should see "([^\"]*)" date value of "([^\"]*)" record$/ do |attr, model|
  steps %Q(Then I should see "#{display_date @records[model][0].send(attr)}")
end

Then /^I should see "([^\"]*)" currency value of "([^\"]*)" record$/ do |attr, model|
  steps %Q(Then I should see "#{amount_to_currency @records[model][0].send(attr)}")
end

Then /^I should see "([^\"]*)" values of "([^\"]*)" records of "([^\"]*)" (\d+) record$/ do |attr, model, parent, ord|
  aggregate = @records[parent][ord.to_i].send model.pluralize
  aggregate.each do |record|
    steps %Q(Then I should see "#{record.send(attr)}")
  end
end

Then /^I should see "([^\"]*)" date values of "([^\"]*)" records of "([^\"]*)" (\d+) record$/ do |attr, model, parent, ord|
  aggregate = @records[parent][ord.to_i].send model.pluralize
  aggregate.each do |record|
    steps %Q(Then I should see "#{display_date record.send(attr)}")
  end
end

Then /^I should see the same "([^"]*)" value$/ do |key|
  steps %Q(Then I should see "#{@values[key]}")
end
