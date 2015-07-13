Rails::TestTask.new("test:services" => "test:prepare") do |t|
  t.pattern = "test/services/*_test.rb"
end

Rails::TestTask.new("test:units" => "test:prepare") do |t|
  t.pattern = "test/units/*_test.rb"
end

Rails::TestTask.new("test:lib" => "test:prepare") do |t|
  t.pattern = "test/lib/**/*_test.rb"
end

Rails::TestTask.new("test:encryptors" => "test:prepare") do |t|
  t.pattern = "test/encryptors/**/*_test.rb"
end

Rails::TestTask.new("test:forms" => "test:prepare") do |t|
  t.pattern = "test/forms/*_test.rb"
end

Rails::TestTask.new("test:features" => "test:prepare") do |t|
  t.pattern = "test/features/**/*_test.rb"
end

Rake::Task["test:run"].enhance ["test:services", "test:units", "test:encryptors",
                                "test:features", "test:lib", "test:forms"]
