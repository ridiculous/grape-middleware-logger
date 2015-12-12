require 'rails_helper'

describe Grape::Middleware::Logger, type: :rails_integration do
  let(:app) { build :app }
  let(:options) { {} }

  subject { described_class.new(app, options) }

  let(:app_response) { build :app_response }
  let(:grape_request) { build :grape_request }
  let(:grape_endpoint) { build(:grape_endpoint) }
  let(:env) { build(:expected_env, grape_endpoint: grape_endpoint) }

  describe '#logger' do
    context 'when @options[:logger] is nil' do
      context 'when Rails.application.config.logger is defined' do
        it 'uses the Rails logger' do
          expect(subject.logger).to be_present
          expect(subject.logger).to be Rails.application.config.logger
          expect(subject.logger.formatter).to be_nil
        end
      end

      context 'when the class logger is nil' do
        before { described_class.logger = nil }

        it 'uses the default logger' do
          expect(subject.logger).to be_present
          expect(subject.logger).to_not be Rails.application.config.logger
          expect(subject.logger).to be_a(Logger)
          expect(subject.logger.formatter.call('foo')).to eq "foo\n"
        end
      end
    end

    context 'when @options[:logger] is set' do
      let(:options) { { logger: Object.new } }

      it 'returns the logger object' do
        expect(subject.logger).to eq options[:logger]
      end
    end
  end

  it 'logs all parts of the request' do
    expect(subject.logger).to receive(:info).with ''
    expect(subject.logger).to receive(:info).with %Q(Started POST "/api/1.0/users" at #{subject.start_time})
    expect(subject.logger).to receive(:info).with %Q(Processing by TestAPI#users)
    expect(subject.logger).to receive(:info).with %Q(  Parameters: {"id"=>"101001", "name"=>"foo", "password"=>"[FILTERED]"})
    expect(subject.logger).to receive(:info).with /Completed 200 in \d+.\d+ms/
    expect(subject.logger).to receive(:info).with ''
    subject.call!(env)
  end

  describe 'the "processing by" section' do
    before { subject.call!(env) }

    context 'namespacing' do
      let(:grape_endpoint) { build(:namespaced_endpoint) }

      it 'ignores the namespacing' do
        expect(subject.processed_by).to eq 'TestAPI#users'
      end

      context 'with more complex route' do
        let(:grape_endpoint) { build(:namespaced_endpoint, :complex) }

        it 'only escapes the first slash and leaves the rest of the untouched' do
          expect(subject.processed_by).to eq 'TestAPI#users/:name/profile'
        end
      end
    end

    context 'with more complex route' do
      let(:grape_endpoint) { build(:grape_endpoint, :complex) }

      it 'only escapes the first slash and leaves the rest of the untouched' do
        expect(subject.processed_by).to eq 'TestAPI#users/:name/profile'
      end
    end
  end
end
