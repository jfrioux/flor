
#
# specifying flor
#
# Wed May 18 13:58:27 JST 2016
#

require 'spec_helper'


describe 'Flor unit' do

  before :each do

    @unit = Flor::Unit.new('.flor-test.conf')
    @unit.conf['unit'] = 'u'
    @unit.storage.migrate
    @unit.start
  end

  after :each do

    @unit.stop
    @unit.storage.clear
    @unit.shutdown
  end

  describe 'cancelling a node' do

    it 'cancels a leaf node' do

      flon = %{
        stall _
      }

      exid = @unit.launch(flon)

      sleep 0.1

      xd = @unit.executions[exid: exid].data

      expect(xd['nodes'].keys).to eq(%w[ 0 ])

      @unit.queue({ 'point' => 'cancel', 'exid' => exid, 'nid' => '0' })

fail
    end

    it 'cancels a node and its children'
  end
end
