chai = require 'chai'
expect = chai.expect

StaticAssets = require '../../src/availableBricks/staticAssets'

describe 'StaticAssets', ->
  it 'should handle strings and object as input data', ->
    testInput = [
      'myStringPath'
      { urlRoot: '/myUrlPathRoot', path: 'myUrlPathPath' }
    ]

    expectedOutput = [
      { urlRoot: '/', path: 'myStringPath' }
      { urlRoot: '/myUrlPathRoot', path: 'myUrlPathPath' }
    ]

    staticAssetsBrick = new StaticAssets()

    actualOutput = staticAssetsBrick._ensureUrlAndPath testInput
    expect(actualOutput).to.eql expectedOutput
    return
  return
