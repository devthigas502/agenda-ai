class EnablePgcryptoExtension < ActiveRecord::Migration[8.1]
  def change
    return unless connection.adapter_name.downcase.include?("postgres")

    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end
