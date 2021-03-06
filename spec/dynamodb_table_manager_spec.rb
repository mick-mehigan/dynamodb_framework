require 'spec_helper'

RSpec.describe DynamoDbTableManager do

  attributes_builder = DynamoDbAttributesBuilder.new

  before do
    attributes_builder = DynamoDbAttributesBuilder.new
    attributes_builder.add(:id, :S)

    subject.create('update_throughput', attributes_builder.attributes, :id)

    subject.create('add_index', attributes_builder.attributes, :id)
  end

  it 'can create, check exists & drop tables' do

    puts 'check if table exists:'
    exists = subject.exists?('create_drop_test')
    puts exists

    if exists
      subject.drop('create_drop_test')
    end

    subject.create('create_drop_test', attributes_builder.attributes, :id)

    subject.drop('create_drop_test')
  end

  it 'can create a table with a hash key and a range key' do

    puts 'check if table exists:'
    exists = subject.exists?('dual_key')
    puts exists

    if exists
      subject.drop('dual_key')
    end

    subject.create('dual_key', attributes_builder.attributes, :id)

    subject.drop('dual_key')

  end

  it 'can create a table with a global secondary index' do

    puts 'check if table exists:'
    exists = subject.exists?('index_test')
    puts exists

    if exists
      subject.drop('index_test')
    end

    global_indexes = []
    index1 = subject.create_global_index('index1', :name, :number)
    global_indexes.push(index1)

    builder = DynamoDbAttributesBuilder.new
    builder.add(:id, :S)
    builder.add(:name, :S)
    builder.add(:number, :N)

    subject.create('index_test', builder.attributes, :id, nil, 20, 10, global_indexes)

    subject.drop('index_test')

  end

  it 'can update the throughput of a table' do

    subject.update_throughput('update_throughput', 30, 30)

  end

  it 'can add a global index to an existing table' do

    builder = DynamoDbAttributesBuilder.new
    builder.add(:id, :S)
    builder.add(:name, :S)

    index = subject.create_global_index('new_index', :name, nil)
    subject.add_index('add_index', builder.attributes, index)

    has_index = subject.has_index?('add_index', 'new_index')

    expect(has_index).to eq(true)

  end

  it 'can update the throughput of a global secondary index' do

    puts 'check if table exists:'
    exists = subject.exists?('update_index_throughput_test')
    puts exists

    if exists
      subject.drop('update_index_throughput_test')
    end

    global_indexes = []
    index1 = subject.create_global_index('index1', :name, :number)
    global_indexes.push(index1)

    builder = DynamoDbAttributesBuilder.new
    builder.add(:id, :S)
    builder.add(:name, :S)
    builder.add(:number, :N)

    subject.create('update_index_throughput_test', builder.attributes, :id, nil, 20, 10, global_indexes)

    subject.update_index_throughput('update_index_throughput_test', 'index1', 50, 50)

    subject.drop('update_index_throughput_test')

  end

  it 'can drop an existing global secondary index' do

    puts 'check if table exists:'
    exists = subject.exists?('drop_index_test')
    puts exists

    if exists
      subject.drop('drop_index_test')
    end

    global_indexes = []
    index1 = subject.create_global_index('index1', :name, :number)
    global_indexes.push(index1)

    builder = DynamoDbAttributesBuilder.new
    builder.add(:id, :S)
    builder.add(:name, :S)
    builder.add(:number, :N)

    subject.create('drop_index_test', builder.attributes, :id, nil, 20, 10, global_indexes)

    subject.drop_index('drop_index_test', 'index1')

    has_index = subject.has_index?('drop_index_test', 'index1')

    subject.drop('drop_index_test')

    expect(has_index).to eq(false)

  end

  after do

    subject.drop('update_throughput')
    subject.drop('add_index')

  end

end