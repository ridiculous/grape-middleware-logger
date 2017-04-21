require 'spec_helper'

describe Grape::Middleware::Logger do
  let(:app) { double('app') }

  subject { described_class.new(app, options) }

  describe '#headers' do
    let(:grape_request) { build :grape_request, :basic_headers }
    let(:env) { build :expected_env, grape_request: grape_request }

    before { subject.instance_variable_set(:@env, env) }

    context 'when @options[:headers] has a symbol :all' do
      let(:options) { { headers: :all, logger: Object.new } }
      it 'all request headers should be retrieved' do
        expect(subject.headers.fetch('Accept-Language')).to eq('en-US')
        expect(subject.headers.fetch('Cache-Control')).to eq('max-age=0')
        expect(subject.headers.fetch('User-Agent')).to eq('Mozilla/5.0')
        expect(subject.headers.fetch('Version')).to eq('HTTP/1.1')
      end
    end

    context 'when @options[:headers] is a string "user-agent"' do
      let(:options) { { headers: 'user-agent', logger: Object.new } }
      it 'only "User-Agent" should be retrieved' do
        expect(subject.headers.fetch('User-Agent')).to eq('Mozilla/5.0')
        expect(subject.headers.length).to eq(1)
      end
    end

    context 'when @options[:headers] is an array of ["user-agent", "Cache-Control", "Unknown"]' do
      let(:options) { { headers: %w(user-agent Cache-Control Unknown), logger: Object.new } }
      it '"User-Agent" and "Cache-Control" should be retrieved' do
        expect(subject.headers.fetch('Cache-Control')).to eq('max-age=0')
        expect(subject.headers.fetch('User-Agent')).to eq('Mozilla/5.0')
      end
      it '"Unknown" name does not make any effect' do
        expect(subject.headers.length).to eq(2)
      end
    end
  end

  describe '#headers if no request header' do
    let(:env) { build :expected_env }
    before { subject.instance_variable_set(:@env, env) }

    context 'when @options[:headers] is set, but no request header is there' do
      let(:options) { { headers: %w(user-agent Cache-Control), logger: Object.new } }
      it 'subject.headers should return empty hash' do
        expect(subject.headers.length).to eq(0)
      end
    end
  end

end

