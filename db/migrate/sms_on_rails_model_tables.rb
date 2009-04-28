    use_fk = respond_to?(:add_foreign_key)
    puts "#{use_fk ? '': 'NOT'} USING FOREIGN KEYS"
    
    create_table :sms_drafts, :force => true do |t|
      t.column :message, :string, :default => nil
      t.column :header, :string, :default => nil
      t.column :footer, :string, :default => nil
      t.column :status, :string, :limit => 15, :null => false, :default => 'NOT_PROCESSED'
      t.column :deliver_after, :datetime, :default => nil
      t.column :delivery_date, :datetime, :default => nil
      t.column :sender_id, :integer, :default => nil
      t.column :lock_version, :integer, :null => false, :default => 0, :limit => 1
      t.column :options, :string, :default => nil
      t.column :updated_at, :string, :default => nil
      t.column :created_at, :string, :default => nil
    end


    #Add a unique id to track vendor
    create_table :sms_outbounds, :force => true do |t|
      t.column :sms_phone_number_id, :integer, :null => false, :on_delete => :cascade
      t.column :sms_draft_id, :integer, :default => nil, :on_delete => :cascade
      t.column :status, :string, :limit => 15, :null => false, :default => 'NOT_PROCESSED'
      t.column :retry_count,  :integer, :limit => 1, :null => false, :default => 0
      t.column :sub_status, :string, :limit => 35, :default => nil
      t.column :notes, :string, :limit => 80, :default => nil
      t.column :created_at, :datetime, :default => nil
      t.column :processed_on, :datetime, :default => nil
      t.column :lock_version, :integer, :null => false, :default => 0, :limit => 1
      t.column :sms_service_provider_id, :integer, :limit => 4, :default => nil, :references => nil
      t.column :options, :string, :default => nil
      t.column :send_priority,  :integer, :limit => 4, :null => false, :default => 0
    end

    execute "ALTER TABLE sms_outbounds ADD COLUMN `unique_id` varchar(255) character set latin1 collate latin1_bin default NULL"
    add_index :sms_outbounds, :unique_id, :unique => 'true', :name => 'uk_sms_outbounds_unique_id'
    add_index :sms_outbounds, [:sms_draft_id, :sms_phone_number_id], :unique => 'true', :name => 'uk_sms_outbounds_draft_phone_number'

    # Add composite accross sms_outbounds for lookup speed
    #add_index :sms_outbounds, [:status, :send_priority, :sms_draft_id], :name => 'idx_sms_outbounds_status_priority_draft'

    #Add a unique id to track vendor
    if use_fk
      #add_foreign_key :sms_outbounds, :sms_draft_id, :sms_drafts, :on_delete => :cascade, :name => 'fk_sms_outbound_draft'
      #add_foreign_key :sms_outbounds, :sms_phone_number_id, :on_delete => :cascade, :name => 'fk_sms_outbound_phone_number_id'
    else
      #add_index :sms_outbounds, :sms_draft_id
      #do not index :sms_draft_id because their is already a composite on
      #draft and phone_number
      add_index :sms_outbounds, :sms_phone_number_id
    end

    #Add a unique id to track vendor
    create_table :sms_inbounds, :force => true do |t|
      t.column :sms_draft_id, :integer, :default => nil, :references => :sms_drafts, :on_delete => :cascade
      t.column :sms_phone_number_id, :integer, :null => false, :references => :sms_phone_number_ids, :on_delete => :cascade
      t.column :created_at, :datetime, :default => nil
      t.column :sent_at, :datetime, :default => nil
      t.column :message, :datetime, :default => nil
      t.column :sms_service_provider_id, :integer, :default => nil, :limit => 1, :references => nil
    end

    execute "ALTER TABLE sms_inbounds ADD COLUMN `unique_id` varchar(255) character set latin1 collate latin1_bin default NULL"

    add_index :sms_inbounds, :unique_id, :unique => 'true', :name => 'uk_sms_inboundes_unique_id'
    unless use_fk
      add_index :sms_inbounds, :sms_draft_id
      add_index :sms_inbounds, :sms_phone_number_id
    end