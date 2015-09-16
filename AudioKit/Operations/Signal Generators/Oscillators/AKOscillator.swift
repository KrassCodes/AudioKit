//
//  AKOscillator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka on 9/16/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A simple oscillator with linear interpolation.

Reads from the table sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
*/
@objc class AKOscillator : AKParameter {

    // MARK: - Properties

    private var osc = UnsafeMutablePointer<sp_osc>.alloc(1)

    /** Initial phase of waveform in functionTable, expressed as a fraction of a cycle (0 to 1). [Default Value: 0] */
    private var phase: Float = 0


    /** Shape of the table to oscillate. [Default Value: sine] */
    var waveform = AKTable.standardSineWave() {
        didSet {
            osc.memory.tbl = waveform.ftbl
        }
    }

    /** Frequency in cycles per second [Default Value: 440] */
    var frequency: AKParameter = akp(440) {
        didSet {
            frequency.bind(&osc.memory.freq)
            dependencies.append(frequency)
        }
    }

    /** Amplitude of the output [Default Value: 1] */
    var amplitude: AKParameter = akp(1) {
        didSet {
            amplitude.bind(&osc.memory.amp)
            dependencies.append(amplitude)
        }
    }


    // MARK: - Initializers

    /** Instantiates the oscillator with default values
    */
    override init()
    {
        super.init()
        setup()
        bindAll()
    }

    /** Instantiates oscillator with constants

    - parameter phase: Initial phase of waveform in functionTable, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
    */
    init (phase iphsInput: Float) {
        super.init()
        setup(iphsInput)
        bindAll()
    }

    /** Instantiates the oscillator with all values

    - parameter waveform: Shape of the table to oscillate. [Default Value: sine]
    - parameter frequency: Frequency in cycles per second [Default Value: 440]
    - parameter amplitude: Amplitude of the output [Default Value: 1]
    - parameter phase: Initial phase of waveform in functionTable, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
    */
    convenience init(
        waveform  tblInput:  AKTable,
        frequency freqInput: AKParameter,
        amplitude ampInput:  AKParameter,
        phase     iphsInput: Float)
    {
        self.init(phase: iphsInput)
        waveform  = tblInput
        frequency = freqInput
        amplitude = ampInput

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal oscillator */
    internal func bindAll() {
        osc.memory.tbl = waveform.ftbl
        frequency.bind(&osc.memory.freq)
        amplitude.bind(&osc.memory.amp)
        dependencies.append(frequency)
        dependencies.append(amplitude)
    }

    /** Internal set up function */
    internal func setup(phase: Float = 0) {
        sp_osc_create(&osc)
        sp_osc_init(AKManager.sharedManager.data, osc, waveform.ftbl, phase)
    }

    /** Computation of the next value */
    override func compute() {
        sp_osc_compute(AKManager.sharedManager.data, osc, nil, &leftOutput);
        rightOutput = leftOutput
    }

    /** Release of memory */
    override func teardown() {
        sp_osc_destroy(&osc)
    }
}
