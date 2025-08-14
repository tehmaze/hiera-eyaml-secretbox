require 'base64'
require 'rbnacl'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/encrypthelper'
require 'hiera/backend/eyaml/logginghelper'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class SecretBox < Encryptor
          VERSION = "0.4.2"

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
            # Receivers public key
            pub = RbNaCl::PublicKey.new(public_key)

            # Senders private key
            key = RbNaCl::PrivateKey.generate
            box = RbNaCl::SimpleBox.from_keypair(pub, key)

            # Public key plus cipher text
            key.public_key.to_str + box.encrypt(plaintext)
          end

          def self.decrypt message
            public_key_bin = message.byteslice(0, RbNaCl::PublicKey::BYTES)
            ciphertext = message.byteslice(RbNaCl::PublicKey::BYTES, message.length)

            # Receivers private key
            key = RbNaCl::PrivateKey.new(private_key)

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

            EncryptHelper.ensure_key_dir_exists private_key
            EncryptHelper.write_important_file :filename => private_key, :content => key_b64, :mode => 0600
            EncryptHelper.ensure_key_dir_exists public_key
            EncryptHelper.write_important_file :filename => public_key, :content => pub_b64, :mode => 0644
            LoggingHelper.info 'Keys created OK'

          end

          def self.public_key
            if ENV['SECRETBOX_PUBLIC_KEY']
              public_key_b64 = ENV['SECRETBOX_PUBLIC_KEY']
            elsif option(:public_key)
              public_key_b64 = File.read(option(:public_key))
            else
              raise StandardError, "secretbox_public_key is not defined"
            end
            Base64.decode64(public_key_b64)
          end
          private_class_method :public_key

          def self.private_key
            if ENV['SECRETBOX_PRIVATE_KEY']
              private_key_b64 = ENV['SECRETBOX_PRIVATE_KEY']
            elsif option(:private_key)
              private_key_b64 = File.read(option(:private_key))
            else
              raise StandardError, "secretbox_private_key is not defined"
            end
            Base64.decode64(private_key_b64)
          end
          private_class_method :private_key
        end

      end

    end

  end

end
