require 'sdp'

module RTSP

  # This module defines the template strings that make up RTSP methods.  Other
  # objects should use these for building request messages to communicate in
  # RTSP.
  module RequestMessages
    RTSP_VER = "RTSP/1.0"
    RTSP_ACCEPT_TYPE = "application/sdp"
    RTP_DEFAULT_PORT = 9000
    RTP_DEFAULT_PACKET_TYPE = "RTP/AVP"
    RTP_DEFAULT_ROUTING = "unicast"
    RTSP_DEFAULT_SEQUENCE_NUMBER = 1
    RTSP_DEFAULT_NPT = "0.000-"

    # OPTIONS request message as defined in section 10.1 of the RFC doc.
    #
    # @param [String] stream
    # @param [Fixnum] sequence
    # @return [String] The formatted request message to send.
    def self.options(stream, sequence=RTSP_DEFAULT_SEQUENCE_NUMBER)
      message =  "OPTIONS #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{sequence}\r\n"
      message << "\r\n"
    end

    # See section 10.2
    # 
    # @param [String] stream
    # @param [Hash] options
    # @option options [Number] sequence
    # @option options [Array<String>] accept The list of description formats the
    # client understands.
    # @return [String] The formatted request message to send.
    def self.describe(stream, options={})
      options[:sequence] ||= RTSP_DEFAULT_SEQUENCE_NUMBER
      options[:accept]   ||= [RTSP_ACCEPT_TYPE]

      accepts = options[:accept] * ", "

      message =  "DESCRIBE #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Accept: #{accepts}\r\n"
      message << "\r\n"
    end

    # @param [String] stream
    # @param [Number] session
    # @param [Hash] options
    # @option options [Fixnum] :sequence The sequence number to use.
    # @option options [String] :content_type Defaults to 'application/sdp'.
    # @option options [SDP::Description] The SDP description to announce.
    # @return [String] The formatted request message to send.
    def self.announce(stream, session, options={})
      sequence =        options[:sequence]      || RTSP_DEFAULT_SEQUENCE_NUMBER
      content_type =    options[:content_type]  || RTSP_ACCEPT_TYPE
      sdp =             options[:sdp]           || SDP::Description.new
      content_length =  sdp.to_s.length         || 0

      message =  "ANNOUNCE #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{sequence}\r\n"
      message << "Date: \r\n"
      message << "Session: #{session}\r\n"
      message << "Content-Type: #{content_type}\r\n"
      message << "Content-Length: #{content_length}\r\n"
      message << "\r\n"
      message << sdp.to_s
    end

    # @return [String] The formatted request message to send.
    def self.setup(track, options={})
      options[:sequence]    ||= RTSP_DEFAULT_SEQUENCE_NUMBER
      options[:transport]   ||= RTP_DEFAULT_PACKET_TYPE
      options[:port]        ||= RTP_DEFAULT_PORT
      options[:routing] ||= RTP_DEFAULT_ROUTING
      message =  "SETUP #{track} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Transport: #{options[:transport]};"
      message <<            "#{options[:destination]};"
      message <<            "client_port=#{options[:port]}-#{options[:port]+1}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.play(stream, session, options={})
      options[:sequence] ||= RTSP_DEFAULT_SEQUENCE_NUMBER
      options[:npt] ||= RTSP_DEFAULT_NPT
      message =  "PLAY #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Session: #{session}\r\n"
      message << "Range: npt=#{options[:npt]}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.pause(stream, session, sequence)
      message =  "PAUSE #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{sequence}\r\n"
      message << "Session: #{session}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.teardown(stream, session, options={})
      options[:sequence] ||= RTSP_DEFAULT_SEQUENCE_NUMBER
      message =  "TEARDOWN #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Session: #{session}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.get_parameter(stream, session, options={})
      message =  "GET_PARAMETER #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Content-Type: #{options[:content_type]}\r\n"
      message << "Content-Length: #{options[:content_length]}\r\n"
      message << "Session: #{session}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.set_parameter(stream, options={})
      message =  "SET_PARAMETER #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Content-Type: #{options[:content_type]}\r\n"
      message << "Content-Length: #{options[:content_length]}\r\n"
      message << "\r\n"
    end

    # @return [String] The formatted request message to send.
    def self.record(stream, session, options={})
      message =  "RECORD #{stream} #{RTSP_VER}\r\n"
      message << "CSeq: #{options[:sequence]}\r\n"
      message << "Session: #{session}\r\n\r\n"
      message << "Conference: #{options[:conference]}\r\n"
      message << "\r\n"
    end
  end
end
