  # AUTO INSTALL PWR-CHAIN VALIDATOR NODE
  

## System Requirements

| Component | Specification |
|-----------|---------------|
| **CPU** | 1 vCPU |
| **Memory** | 1 GB RAM |
| **Disk** | 25 GB HDD or higher |
| **Open TCP Ports** | 8231, 8085 |
| **Open UDP Port** | 7621 |

### Recommended Hardware
- Minimum Specifications: As listed above
- Recommended: 2 vCPU, 2 GB RAM, 50 GB SSD
- Stable and reliable internet connection
- Linux-based OS (Ubuntu 20.04 LTS or newer recommended)

## 1. Download Setup
```bash
wget https://raw.githubusercontent.com/dwisetyawan00/PWR-Chain/main/pwr-setup.sh && chmod +x pwr-setup.sh && ./pwr-setup.sh
```
## 2. Cek Private-key kalian yang telah kalian bikin
```bash
sudo java -jar validator.jar get-private-key password
```

## 3. Cek address kalian
```bash
curl http://[IP_VPS_ANDA]:8085/address/
```

## 4. Join Discord dan Claim faucet jika sudah mendapatkan role
- Join Discord [Disini](https://discord.gg/C3PRdT7N)
- Claim Validator di Server #Validator-Node-Application
- Open Ticket
### *Jika sudah mendapatkan role*
- Ke Server #PWR-Chain (Claim Faucet Kalo Udah Punya Role)
- Ketik /claim *`address-kalian-tadi`*

## 🔴 5. Hapus instalasi node ( PASTIKAN ANDA MEMANG INGIN MENGHAPUSNYA )
```bash
wget https://raw.githubusercontent.com/dwisetyawan00/PWR-Chain/main/cleanup_validator.sh && chmod +x cleanup_validator.sh && sudo ./cleanup_validator.sh
```

## 6. Command tambahan jika diperlukan :
  ### 🟡 Restart Node
```bash
sudo systemctl restart pwr-validator
```
  ### 🔴 Stop Node
```bash
sudo systemctl stop pwr-validator
```
  ### 🟢 Start Node
```bash
sudo systemctl start pwr-validator
```
  ### 🔵 Check Status Node
```bash
sudo systemctl status pwr-validator
```
  ### ⚫ Check Log
```bash
sudo journalctl -u pwr-validator.service
```        

