describe 'Rails' do
  it { expect(Rails.logger).to eq Sails.logger }
  it { expect(Rails.cache).to eq Sails.cache }
  it { expect(Rails.env).to eq Sails.env }
  it { expect(Rails.root).to eq Sails.root }
end