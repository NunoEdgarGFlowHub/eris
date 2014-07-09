#!/usr/bin/env ruby

helpers do
  def address_guard contract
    contract = "0x#{contract}" unless contract[0..1] == '0x'
    contract
  end

  def address_unguard contract
    if contract.class == String
      contract = '0x0' if contract == '0x'
      contract = contract[2..-1] if contract[0..1] == '0x'
    elsif contract.class == Array
      tmp = []
      until contract.empty?
        c = contract.shift
        if c.class == String
          c = c[2..-1] if c[0..1] == '0x'
        else
          c = '0x'
        end
        tmp.push c
      end
      contract = tmp
    end
    contract
  end

  def find_the_peak contract
    lineage  = []
    parent   = Celluloid::Actor[:eth].get_storage_at contract, '0x14'
    until parent == '0x'
      lineage << parent
      child  = parent
      parent = Celluloid::Actor[:eth].get_storage_at parent, '0x14'
      break if child == parent
    end
    return lineage
  end

  def get_dougs_storage position
    unless position[0..1] == '0x'
      position = EPM::HexData.construct_data [position]
    end
    begin
      return Celluloid::Actor[:eth].get_storage_at $doug, position
    rescue
    end
  end

  def contract_type this_contract, contents, lineage
    # type 0 is a post||individual blob
    # type 1 is a thread||middle group level
    # type 2 is a topic||high group level
    # type 3 is a swarum_top||top level AB
    begin
      if contents.count == 1 && this_contract == contents.first.first[0]
        return 0
      elsif lineage.count == 0
        return 3
      elsif lineage.count == 1
        return 2
      end
    end
    return 1
  end

  def assemble_content_votes
    if @type == 0 || @type == 1
      i = 0
      @upvotes       = []
      @downvotes     = []
      @contents.each do |group|
        group.each do |contract,contents|
          @upvotes[i]   = address_unguard(contract_upvotes(contract)).to_i
          @downvotes[i] = address_unguard(contract_downvotes(contract)).to_i
        end
        i += 1
      end
    else
      @upvotes   = [0]
      @downvotes = [0]
    end
  end

  def contract_upvotes this_contract
    return Celluloid::Actor[:eth].get_storage_at this_contract, '0x19'
  end

  def contract_downvotes this_contract
    return Celluloid::Actor[:eth].get_storage_at this_contract, '0x20'
  end

  def get_watched_contracts
    watch_file = ENV['WATCH_FILE']
    begin
      watched = JSON.parse(File.read(watch_file))
    rescue
      watched = []
    end
  end

  def get_ignored_contracts
    ignore_file = ENV['IGNORE_FILE']
    begin
      ignored = JSON.parse(File.read(ignore_file))
    rescue
      watched = []
    end
  end

  def update_settings params
    epm_settings_file = File.join(ENV['HOME'], '.epm', 'epm-rpc.json')
    c3d_settings_file = File.join(ENV['HOME'], '.epm', 'c3d-config.json')
    @epm_settings = JSON.parse(File.read(epm_settings_file))
    if @epm_settings && params[:epmAndC3d] && params[:epmAndC3d] == "on"
      @epm_settings['path-to-eth']         = params[:pathtoEth]
      @epm_settings['json-port']           = params[:ethRPCPort]
      @epm_settings['remote']              = params[:ethPeerServer]
      @epm_settings['eth-listen-port']     = params[:ethPeerPort]
      @epm_settings['directory']           = params[:blockchainDir]
      @epm_settings['address-public-key']  = address_guard params[:primaryAccountPub]
      @epm_settings['address-private-key'] = address_guard params[:primaryAccountPriv]
    end
    @c3d_settings = JSON.parse(File.read(c3d_settings_file))
    if @c3d_settings
      @c3d_settings['swarm_dir']             = params[:swarmDir]
      @c3d_settings['path-to-eth']           = params[:pathtoEth]
      @c3d_settings['eth_rpc_port']          = params[:ethRPCPort]
      @c3d_settings['eth_remote']            = params[:ethPeerServer]
      @c3d_settings['eth_peer_port']         = params[:ethPeerPort]
      @c3d_settings['blockchain_dir']        = params[:blockchainDir]
      @c3d_settings['primary_account']       = address_guard params[:primaryAccountPub]
      @c3d_settings['primary_account_key']   = address_guard params[:primaryAccountPriv]
      @c3d_settings['torrents_dir']          = params[:torrentsDir]
      @c3d_settings['blobs_dir']             = params[:blobsDir]
      @c3d_settings['watch_file']            = params[:watchFile]
      @c3d_settings['ignore_file']           = params[:ignoreFile]
      @c3d_settings['torrent_rpc']           = params[:torrentRPCadd]
      @c3d_settings['torrent_user']          = params[:torrentUserName]
      @c3d_settings['torrent_pass']          = params[:torrentPassword]
      @c3d_settings['path-to-lllc']          = params[:pathtoLLLC]
      @c3d_settings['download_dir']          = params[:downloadingDir]
      @c3d_settings['download-queue-size']   = params[:downloadQueueSize]
      @c3d_settings['queue-stalled-minutes'] = params[:queueStallMins]
      @c3d_settings['gas_price']             = params[:gasPrice]
    end
    File.open(epm_settings_file, 'w'){|f| f.write(JSON.pretty_generate(@epm_settings))}
    File.open(c3d_settings_file, 'w'){|f| f.write(JSON.pretty_generate(@c3d_settings))}
    restart_eris
  end

  def restart_eris
    C3D::SetupC3D.new
    Celluloid::Actor[:puller].terminate
    Celluloid::Actor[:eth].terminate
    C3D::ConnectTorrent.supervise_as :puller, {
        username: ENV['TORRENT_USER'],
        password: ENV['TORRENT_PASS'],
        url:      ENV['TORRENT_RPC'] }
    C3D::ConnectEth.supervise_as :eth, :cpp
    C3D::Utility.save_key
    $key = Celluloid::Actor[:eth].get_key
  end

  def stop_eth
    Celluloid::Actor[:eth].terminate
    sleep 1
    if C3D::EthRunner.is_eth_running?
      eth = C3D::EthRunner.eth_process
      spawn "kill #{eth}"
    end
  end

  def kank_chain
    chain = ENV['BLOCKCHAIN_DIR']
    chain.gsub!('~', ENV['HOME']) if chain[/~/]
    FileUtils.rm_rf chain
  end

  def start_eth
    print "This will take a few seconds. Please be patient.\n"
    settings = C3D::Utility.get_config
    C3D::EthRunner.start_ethereum settings
    C3D::ConnectEth.supervise_as :eth, :cpp
    $key = Celluloid::Actor[:eth].get_key
  end

  def get_latest_doug
    log_file = File.join(ENV['HOME'], '.epm', 'deployed-log.csv')
    begin
      log  = File.read log_file
      doug = log.split("\n").map{|l| l.split(',')}.select{|l| l[0] == ("Doug" || "DOUG" || "doug")}[-1][-1]
    rescue
      doug = '0x'
    end
    doug_check = Celluloid::Actor[:eth].get_storage_at doug, '0x10'
    if doug_check != '0x'
      return doug
    else
      return nil
    end
  end
end