describe Fastlane::Actions::IonicAction do
  describe '#run' do
  end

  describe '#check_platform' do
    before do
      allow(File).to receive(:directory?).and_return(false)
    end

    let (:params) { {} }

    describe 'platform missing' do
      it 'platform = android' do
        params[:platform] = 'android'
        result = Fastlane::Actions::IonicAction.check_platform(params);
        expect(result).to eq("ionic cordova platform add android --no-interactive")
      end

      it 'platform = ios' do
        params[:platform] = 'ios'
        result = Fastlane::Actions::IonicAction.check_platform(params);
        expect(result).to eq("ionic cordova platform add ios --no-interactive")
      end

      it 'platform = android + nofetch' do
        params[:platform] = 'android'
        params[:cordova_no_fetch] = true
        result = Fastlane::Actions::IonicAction.check_platform(params);
        expect(result).to eq("ionic cordova platform add android --no-interactive --nofetch")
      end
    end

    describe 'platform exists' do
      before do
        allow(File).to receive(:directory?).and_return(true)
      end

      it 'platform = android' do
        params[:platform] = 'android'
        result = Fastlane::Actions::IonicAction.check_platform(params);
        expect(result).to eq(nil)
      end
    end
  end

  describe '#get_args' do
    let (:params) { {} }

        #params[:release] ? '--release' : '--debug']
        #args << '--device' if params[:device]
        #args << '--prod' if params[:prod]
        #args << '--browserify' if params[:browserify]
        #if !params[:cordova_build_config_file].to_s.empty?
        #  args << "--buildConfig=#{

    it 'none' do
      result = Fastlane::Actions::IonicAction.get_args(params);
      expect(result).to eq(['--debug'])
    end

    it 'release, device, prod, browserify, cordova_build_config_file' do
      params = { :release => true, :device => true, :prod => true, :browserify => true, :cordova_build_config_file => 'foo'}
      result = Fastlane::Actions::IonicAction.get_args(params);
      expect(result).to eql(['--release', '--device', '--prod', '--browserify', '--buildConfig=foo'])
    end

    it 'cordova_build_config_file = path with space' do
      path = "path with space"
      params = { :cordova_build_config_file => path}
      result = Fastlane::Actions::IonicAction.get_args(params);
      expect(result).to eql(['--debug', "--buildConfig=#{path.shellescape}"])
    end
  end
end
