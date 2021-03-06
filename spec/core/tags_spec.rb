
#
# specifying flor
#
# Thu May 26 21:03:50 JST 2016
#

require 'spec_helper'


describe 'Flor core' do

  before :each do

    @executor = Flor::TransientExecutor.new
  end

  describe 'the tag attribute' do

    it 'induces messages to be tagged' do

      r = @executor.launch(
        %q{
          sequence tag: 'aa'
            sequence tag: 'bb'
        })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_0:
        execute:0_1_0_0:
        receive:0_1_0:
        execute:0_1_0_1:
        receive:0_1_0:
        entered:0_1:bb
        receive:0_1:
        receive:0:
        left:0_1:bb
        receive::
        left:0:aa
        terminated::
      ].join("\n"))
    end
  end

  describe 'the tags attribute' do

    it 'lets multiple tags be flagged at once' do

      r = @executor.launch(
        %q{
          sequence tag: 'aa', tag: 'bb'
            sequence tags: [ 'cc', 'dd' ]
        })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .collect { |m|
            [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':') }
          .join("\n")
      ).to eq(%w[
        execute:0:
        execute:0_0:
        execute:0_0_0:
        receive:0_0:
        execute:0_0_1:
        receive:0_0:
        entered:0:aa
        receive:0:
        execute:0_1:
        execute:0_1_0:
        receive:0_1:
        execute:0_1_1:
        receive:0_1:
        entered:0:bb
        receive:0:
        execute:0_2:
        execute:0_2_0:
        execute:0_2_0_0:
        receive:0_2_0:
        execute:0_2_0_1:
        execute:0_2_0_1_0:
        receive:0_2_0_1:
        execute:0_2_0_1_1:
        receive:0_2_0_1:
        receive:0_2_0:
        entered:0_2:cc,dd
        receive:0_2:
        receive:0:
        left:0_2:cc,dd
        receive::
        left:0:aa,bb
        terminated::
      ].join("\n"))
    end

    it 'fails on non-string attributes' do

      r = @executor.launch(
        %q{
          sequence tag: aa
            1
        })

      expect(r['point']).to eq('failed')
    end

    it 'accepts procs as tags' do

      r = @executor.launch(
        %q{
          sequence tag: sequence
        })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0:sequence
      ].join("\n"))
    end

    it 'accepts functions as tags' do

      r = @executor.launch(
        %q{
          define x \ _
          sequence tag: x
        })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0_1:x
      ].join("\n"))
    end

    it 'accepts functions as tags (closure)' do

      r = @executor.launch(
        %q{

          define make_tag x
            def \ sequence tag: x

          define t1 \ _

          #set v \ make_tag t1
            # or
          set v (make_tag t1)

          v _
          v _
        })

      expect(r['point']).to eq('terminated')

      expect(
        @executor.journal
          .inject([]) { |a, m|
            next a unless m['point'] == 'entered'
            a << [ m['point'], m['nid'], (m['tags'] || []).join(',') ].join(':')
            a
          }.join("\n")
      ).to eq(%w[
        entered:0_0_2_0-2:t1
        entered:0_0_2_0-3:t1
      ].join("\n"))
    end
  end

  describe 'the tag pseudo-variable' do

    it 'yields null when the tag is not set' do

      r = @executor.launch(
        %q{
          set a []
          push a tag.x
          null
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq([ nil ])
    end

    it 'yields the array of nids with the tag on' do

      r = @executor.launch(
        %q{
          set a []
          sequence tag: 'alpha'
            sequence tag: 'bravo'
              push a tag.bravo
              push a t.alpha
          null
        })

      expect(r['point']).to eq('terminated')
      expect(r['vars']['a']).to eq([ [ '0_1_1' ], [ '0_1' ] ])
    end
  end
end

