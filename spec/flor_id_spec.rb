
#
# specifying flor
#
# Tue Mar  1 07:10:14 JST 2016
#

require 'spec_helper'


describe Flor do

  describe '.next_child_id' do

    it 'works' do

      expect(Flor.next_child_id('0_0')).to eq(1)
      expect(Flor.next_child_id('0_0_9')).to eq(10)
      expect(Flor.next_child_id('0_0_9-3')).to eq(10)
    end
  end

  describe '.parent_id' do

    it 'works' do

      expect(Flor.parent_id('0')).to eq(nil)
      expect(Flor.parent_id('0_1')).to eq('0')
      expect(Flor.parent_id('0_1_9')).to eq('0_1')
      expect(Flor.parent_id('0_1_9-6')).to eq('0_1')
    end
  end

  describe '.child_id' do

    it 'works' do

      expect(Flor.child_id('0')).to eq(0)
      expect(Flor.child_id('0_1')).to eq(1)
      expect(Flor.child_id('0_1_7')).to eq(7)
      expect(Flor.child_id('0_1_9-6')).to eq(9)
    end
  end

  describe '.master_nid' do

    it 'removes the sub_nid' do

      expect(Flor.master_nid('0_7-1')).to eq('0_7')
    end

    it "doesn't remove a missing sub_nid" do

      expect(Flor.master_nid('0_5')).to eq('0_5')
    end
  end

  describe '.child_nid(nid, i)' do

    it 'adds the given id to make a new nid' do

      expect(
        Flor.child_nid('0_0_0', 11)
      ).to eq(
        '0_0_0_11'
      )
    end
  end

  describe '.child_nid(nid, i, sub)' do

    it 'ads the given id and the given sub to make a new nid' do

      expect(
        Flor.child_nid('0_0_0', 11, 0)
      ).to eq(
        '0_0_0_11'
      )
      expect(
        Flor.child_nid('0_0', 12, 1)
      ).to eq(
        '0_0_12-1'
      )
    end
  end

  describe '.nid_distance(nid0, nid1)' do

    it 'returns 0 when the nids are at the same level' do

      expect(Flor.nid_distance('0_0', '0_1')).to eq(0)
      expect(Flor.nid_distance('0_0', '0_0-1')).to eq(0)
    end

    it 'returns 1 when father and child' do

      expect(Flor.nid_distance('0_0', '0_0_1')).to eq(1)
      expect(Flor.nid_distance('0_0', '0_0_2-1')).to eq(1)
    end

    it 'returns 2 when grand-father and child' do

      expect(Flor.nid_distance('0_0', '0_1_0_1')).to eq(2)
      expect(Flor.nid_distance('0_0', '0_3_0_2-1')).to eq(2)
    end
  end
end

