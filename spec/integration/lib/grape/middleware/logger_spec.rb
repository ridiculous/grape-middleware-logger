require 'spec_helper'

describe Grape::Middleware::Logger, type: :integration do
  let(:app) { build :app }
  let(:options) { { filter: build(:param_filter), logger: Logger.new(Tempfile.new('logger')) } }

  subject { described_class.new(app, options) }

  let(:app_response) { build :app_response }
  let(:grape_request) { build :grape_request }
  let(:grape_endpoint) { build(:grape_endpoint) }
  let(:env) { build(:expected_env, grape_endpoint: grape_endpoint) }

  context 'when the option[:one_line] is false' do
    let(:options) { { filter: build(:param_filter), logger: Logger.new(Tempfile.new('logger')), one_line: false } }

    it 'logs all parts of the request on multiple lines' do
      expect(subject.logger).to receive(:info).with ''
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
      expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI/users)
      expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
      expect(subject.logger).to receive(:info).with ''
      subject.call!(env)
    end
  end

  context 'when the options[:one_line is true' do
    let(:options) { { filter: build(:param_filter), logger: Logger.new(Tempfile.new('logger')), one_line: true } }

    it 'logs all parts of the request on one line' do
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time} - Processing by TestAPI/users - Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
      subject.call!(env)
    end
  end

  context 'when an exception occurs' do
    it 'logs all parts of the request including the error class' do
      expect(subject.logger).to receive(:info).with ''
      expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
      expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI/users)
      expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "secret"=>"[FILTERED]", "customer"=>[], "name"=>"foo", "password"=>"[FILTERED]"})
      expect(subject.logger).to receive(:info).with %Q(  ArgumentError: Whoops)
      expect(subject.logger).to receive(:info).with /Completed 500 in \d+\.\d+ms/
      expect(subject.logger).to receive(:info).with ''
      expect(subject.app).to receive(:call).and_raise(ArgumentError, 'Whoops')
      expect {
        subject.call!(env)
      }.to raise_error(ArgumentError)
    end
  end

  describe 'the "processing by" section' do
    before { subject.call!(env) }

    context 'namespacing' do
      let(:grape_endpoint) { build(:namespaced_endpoint) }

      it 'ignores the namespacing' do
        expect(subject.processed_by).to eq 'TestAPI/admin/users'
      end

      context 'with more complex route' do
        let(:grape_endpoint) { build(:namespaced_endpoint, :complex) }

        it 'only escapes the first slash and leaves the rest of the untouched' do
          expect(subject.processed_by).to eq 'TestAPI/admin/users/:name/profile'
        end
      end
    end

    context 'with more complex route' do
      let(:grape_endpoint) { build(:grape_endpoint, :complex) }

      it 'only escapes the first slash and leaves the rest of the untouched' do
        expect(subject.processed_by).to eq 'TestAPI/users/:name/profile'
      end
    end
  end

end
