require 'spec_helper'

describe Grape::Middleware::Logger, type: :integration do
  let(:app) { build :app }

  subject { described_class.new(app, options) }

  let(:grape_endpoint) { build(:grape_endpoint) }
  let(:env) { build(:expected_env, :prefixed_basic_headers, grape_endpoint: grape_endpoint) }

  context ':all option is set to option headers' do
    let(:options) { {
        filter: build(:param_filter),
        headers: :all,
        logger: Logger.new(Tempfile.new('logger'))
    } }
    it 'all headers will be shown, headers will be sorted by name' do
      expect(subject.logger).to receive(:info).with ''
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
      expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI/users)
      expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with %Q(  Headers: {"Cache-Control"=>"max-age=0", "User-Agent"=>"Mozilla/5.0"})
      expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
      expect(subject.logger).to receive(:info).with ''
      subject.call!(env)
    end
  end

  context 'list of names ["User-Agent", "Cache-Control"] is set to option headers' do
    let(:options) { {
        filter: build(:param_filter),
        headers: %w(User-Agent Cache-Control),
        logger: Logger.new(Tempfile.new('logger'))
    } }
    it 'two headers will be shown' do
      expect(subject.logger).to receive(:info).with ''
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
      expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI/users)
      expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with %Q(  Headers: {"Cache-Control"=>"max-age=0", "User-Agent"=>"Mozilla/5.0"})
      expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
      expect(subject.logger).to receive(:info).with ''
      subject.call!(env)
    end
  end

  context 'a single string "Cache-Control" is set to option headers' do
    let(:options) { {
        filter: build(:param_filter),
        headers: 'Cache-Control',
        logger: Logger.new(Tempfile.new('logger'))
    } }
    it 'only Cache-Control header will be shown' do
      expect(subject.logger).to receive(:info).with ''
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
      expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI/users)
      expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with %Q(  Headers: {"Cache-Control"=>"max-age=0"})
      expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
      expect(subject.logger).to receive(:info).with ''
      subject.call!(env)
    end
  end

end
