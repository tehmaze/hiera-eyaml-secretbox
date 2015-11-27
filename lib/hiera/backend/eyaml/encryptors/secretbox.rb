require 'base64'
require 'rbnacl'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class SecretBox < Encryptor
          VERSION = "0.2.2"

          self.options = {
            :private_key => { :desc => "Path to private key",
                              :type => :string,
                              :default => "./keys/private_key.box" },
            :public_key => { :desc => "Path to public key",
                             :type => :string,
                             :default => "./keys/public_key.box" },
          }

          self.tag = 'SecretBox'

          def self.encrypt plaintext
            public_key = self.option :public_key
            raise StandardError, "secretbox_public_key is not defined" unless public_key

            # Receivers public key
            public_key_b64 = File.read public_key
            public_key_bin = Base64.decode64 public_key_b64
            pub = RbNaCl::PublicKey.new(public_key_bin)

            # Senders private key
            key = RbNaCl::PrivateKey.generate
            box = RbNaCl::SimpleBox.from_keypair(pub, key)

            # Public key plus cipher text
            key.public_key.to_str + box.encrypt(plaintext)
          end

          def self.decrypt message
            public_key_bin = message.byteslice(0, RbNaCl::PublicKey::BYTES)
            ciphertext = message.byteslice(RbNaCl::PublicKey::BYTES, message.length)

            private_key = self.option :private_key
            raise StandardError, "secretbox_private_key is not defined" unless private_key

            # Receivers private key
            private_key_b64 = File.read private_key
            private_key_bin = Base64.decode64 private_key_b64
            key = RbNaCl::PrivateKey.new(private_key_bin)

            # Senders public key
            pub = RbNaCl::PublicKey.new(public_key_bin)

            # Decrypted cipher text
            box = RbNaCl::SimpleBox.from_keypair(pub, key)
            box.decrypt(ciphertext)
          end

          def self.create_keys
            public_key = self.option :public_key
            private_key = self.option :private_key
            raise StandardError, 'secretbox_public_key is not defined' unless public_key
            raise StandardError, 'secretbox_private_key is not defined' unless private_key

            key = RbNaCl::PrivateKey.generate
            key_b64 = Base64.encode64 key.to_bytes
            pub = key.public_key
            pub_b64 = Base64.encode64 pub.to_bytes

            Utils.ensure_key_dir_exists private_key
            Utils.write_important_file :filename => private_key, :content => key_b64, :mode => 0600
            Utils.ensure_key_dir_exists public_key
            Utils.write_important_file :filename => public_key, :content => pub_b64, :mode => 0644
            Utils.info 'Keys created OK'

          end

        end

      end

    end

  end

end
