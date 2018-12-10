describe Fastlane::Actions::IonicAction do
  describe '#run' do
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
  end
end
