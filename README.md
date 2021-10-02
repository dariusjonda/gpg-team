# gpg-team
`gpg-team` is a very simplistic gpg wrapper that aids in encrypting and re-encrypting files based on a recipients list (recipients.txt).

The purpose of this script is to have a simple, gpg-based solution that can be used in small teams to handle sensitive information (like database connections or other credentials) for encrypting new files and (quickly) reencrypt already encrypted files in case the recipients change (e.g. new team member, permission changed)


## Installation
**Installation**:  
just clone the repo and use the `make` utility: 
```
git clone https://github.com/dariusjonda/gpg-team.git
cd gpg-team
make clean install
```
`gpg-team` should now be installed in `~/.local/bin/gpg-team`

## Usage
- `cd gpg-team` to get into repo directory.  
- create `recipients.txt` file in the main project directory containing the
  recipients that are being used for encryption. Each recipient needs to be
  on it's own line.

#### Encrypt a new file (plaintext)
  This should be used on a file that is plain text and not encrypted yet.
  ```
  gpg-team -e recipients.txt file
  ```
  **Note:** after successful encryption you will be asked whether to keep the plaintext file or not. Please make sure to delete plaintext files containing credentials in order to prevent exploits.


#### Re-encrypt a *.gpg file
  This should be used on an already encrypted *.gpg file in case you want to reencrypt it using an updated recipients list.
  ```
  gpg-team -r recipients.txt file.gpg 
  ```

#### Re-encrypt all *.gpg files in the present directory
  This should be used in case all the gpg files in the present directory should be reencrypted.  
  ```
  gpg-team -a recipients.txt
  ```
  **Note:** Only do this if you are sure that every file needs to be reencrypted!

## Tutorials

### Creating and using a new GPG keypair (secret and public key)

1. **Creating a new GPG keypair**:  
   the following command will create a new secret key based on the default parameters used by gpg (RSA2048 and expiry in two years).  
   To have more control about the options use `gpg --full-generate-key`
   ```
   gpg --generate-key
   ```
   for identification purposes you need to enter your name and email address.
   Please use your real name / email address to make it easier to identify you for encrypting data.
2. **Check your GPG secret key**:  
   check if your key has been successfully created by typing:
   ```
   gpg --list-secret-keys
   ```
3. **Export your public key**:  
   in order for others to encrypt data for you, they will need your public key.  
   The public key can be exported using the following command. We use the `--armor` flag to have it in an ASCII-armored format (unencoded) to be able to also copy & paste the contents in case we need to:
   ```
   gpg --export --armor your-email-address > ~/my-name_public-key.asc
   ```
   
4. **Import the public key from another person**:  
   For you intend to encrypt files for other people, you need to have their public key in your keychain (check `gpg --list-keys`).  
   You can import public keys using the following command:
   ```
   gpg --import name-of-public-key.asc
   ```
5. **Encrypt a file for someone else**:  
   To encrypt a file for someone else from your keychain (a person you have the public key imported already) you can use the `--encrypt` (short `-e`) and `--recipient` (short `-r`) flags:
   ```
   gpg --encrypt --recipient email-or-name-of-recipient file-to-encrypt
   ```
   You can also skip the recipient flag which will prompt you after entering the command.
6. **Decrypt a file**:  
   If the file has been properly encrypted using your public key, you should now be able to decrypt it's content using your private key. To do so, just use the `--decrypt` (short `-d`) flag:
   ```
   gpg --decrypt file-to-decrypt.gpg
   ```
   This will output the content in the terminal. If you want to store it in a file, just write it to another file:
   ```
   gpg --decrypt file-to-decrypt.gpg > decrypted-filename.txt
   ```

### Exporting GPG secret key and using it on another server

1. **Check for existing GPG secret keys on server #1**:  
    Check for existing secret keys first and look for email address of GPG key you want to export.  
    In case you are not sure if there are GPG private keys already installed repeat that process on Server #2 as well.
    ```
    gpg --list-secret-keys
    ```

2. **Export GPG secret key from server #1**:  
    export your secret key by referring to it's email address. Instead of `secret_key.gpg` you can use any filename you want
    ```
    gpg --export-secret-keys your-email-address > ~/secret_key.gpg
    ```

3. **Transfer GPG secret key**:  
    in order to import this secret key on another server, we have to move it there. Either use SCP (if you can SSH into the other server) or use a network drive as a temporary location to store your secret key (*note to delete the secret key after you're done!*)
    In this example we move the file to `/nfs/shared_drive/` (you can use that directory as well)
    ```
    mv ~/secret_key.gpg /nfs/shared_drive/
    ```

    the `secret_key.gpg` should now be stored under `/nfs/shared_drive/`. Either confirm that with the `ls` command or user your explorer.

4. **Import GPG secret key on server #2**:  
    open the terminal somewhere on server #2 and import the secret_key that you have (temporarily) exported
    ```
    gpg --import /nfs/shared_drive/secret_key.gpg
    ```
    doing so will prompt pinentry to enter your GPG password. If the password was entered correctly, you will get the notification that the import was successfull and you should be able to view the secret key in your gpg keychain typing:

    ```
    gpg --list-secret-keys
    ```
    if you can see the gpg secret key in your keychain, proceed further. Otherwise go back and repeat the previous steps.

    **DO NOT FORGET TO DELETE YOUR SECRET_KEY THAT YOU STORED ON THE NETWORK DRIVE** if you haven't done so already:
    ```
    rm /nfs/shared_drive/secret_key.gpg
    ```

5. **Trust your GPG key**:  
    Before using the newly imported GPG Key, trust it first:
    ``` 
    gpg --edit-key your-email-address
    ```
    this will open a GPG prompt. Type `trust` -> `5` -> `y` -> `save` to trust it ultimately and save your changes. If done correctly this should close the GPG prompt.
