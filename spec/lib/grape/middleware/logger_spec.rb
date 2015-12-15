require 'spec_helper'

describe Grape::Middleware::Logger do
  let(:app) { double('app') }
  let(:options) { { filter: build(:param_filter), logger: Object.new } }

  subject { described_class.new(app, options) }

  let(:app_response) { build :app_response }
  let(:grape_request) { build :grape_request }
  let(:env) { build(:expected_env) }

  describe '#call!' do
    context 'when calling the app results in an error response' do
      let(:error) { { status: 400 } }

      it 'calls +after_failure+ and rethrows the error' do
        expect(app).to receive(:call).with(env).and_throw(:error, error)
        expect(subject).to receive(:before)
        expect(subject).to receive(:after_failure).with(error)
        expect(subject).to receive(:throw).with(:error, error)
        subject.call!(env)
      end
    end

    context 'when there is no error' do
      it 'calls +after+ with the correct status' do
        expect(app).to receive(:call).with(env).and_return(app_response)
        expect(subject).to receive(:before)
        expect(subject).to receive(:after).with(200)
        subject.call!(env)
      end

      it 'returns the @app_response' do
        expect(app).to receive(:call).with(env).and_return(app_response)
        allow(subject).to receive(:before)
        allow(subject).to receive(:after)
        expect(subject.call!(env)).to eq app_response
      end
    end

    context 'when calling the app results in an array response' do
      let(:app_response) { [401, {}, []] }

      it 'calls +after+ with the correct status' do
        expect(app).to receive(:call).with(env).and_return(app_response)
        expect(subject).to receive(:before)
        expect(subject).to receive(:after).with(401)
        subject.call!(env)
      end

      it 'returns the @app_response' do
        expect(app).to receive(:call).with(env).and_return(app_response)
        allow(subject).to receive(:before)
        allow(subject).to receive(:after)
        expect(subject.call!(env)).to eq app_response
      end
    end
  end

  describe '#after_failure' do
    let(:error) { { status: 403 } }

    it 'calls +after+ with the :status' do
      expect(subject).to receive(:after).with(403)
      subject.after_failure(error)
    end

    context 'when :message is set in the error object' do
      let(:error) { { message: 'Oops, not found' } }

      it 'logs the error message' do
        allow(subject).to receive(:after)
        expect(subject.logger).to receive(:info).with(Regexp.new(error[:message]))
        subject.after_failure(error)
      end
    end
  end

  describe '#parameters' do
    before { subject.instance_variable_set(:@env, env) }

    context 'when @options[:filter] is set' do
      it 'calls +filter+ with the raw parameters' do
        expect(subject.options[:filter]).to receive(:filter).with({ "id" => '101001', "name" => "foo", "password" => "access" })
        subject.parameters
      end

      it 'returns the filtered results' do
        expect(subject.parameters).to eq({ "id" => '101001', "name" => "foo", "password" => "[FILTERED]" })
      end
    end

    context 'when @options[:filter] is nil' do
      let(:options) { {} }

      it 'returns the params extracted out of @env' do
        expect(subject.parameters).to eq({ "id" => '101001', "name" => "foo", "password" => "access" })
      end
    end
  end
end
