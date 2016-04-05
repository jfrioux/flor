
#
# specifying flor
#
# Sat Jan  9 07:20:32 JST 2016
#

require 'spec_helper'


describe 'Flor procedures' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'sequence' do

    it 'returns immediately if empty' do

      rad = %{
        sequence _
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({})
    end

    it 'chains children' do

      rad = %{
        sequence
          set f.a
            0
          set f.b
            1
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'a' => 0, 'b' => 1, 'ret' => nil })
    end

    it 'returns the value of last child as $(ret)' do

      rad = %{
        sequence
          1
          2
      }

      r = @executor.launch(rad)

      expect(r['point']).to eq('terminated')
      expect(r['payload']).to eq({ 'ret' => 2 })
    end
  end
end
