#include "Sha256.hpp"

#include <vector>

#include <openssl/hmac.h>
#include <openssl/sha.h>

namespace
{
  std::string b2aToHex(unsigned char* hash, int len)
  {
    static const char hexCharacters[] = "0123456789abcdef";
    std::string result(len * 2, ' ');
    for (int i = 0; i < len; i++)
    {
      result[2 * i] = hexCharacters[(unsigned int)hash[i] >> 4];
      result[2 * i + 1] = hexCharacters[(unsigned int)hash[i] & 0x0F];
    }
    return result;
  }
} // namespace

std::string utils::crypto::sha256(std::string const& input)
{
  unsigned char hash[SHA256_DIGEST_LENGTH];
  SHA256(reinterpret_cast<const unsigned char*>(input.c_str()), input.length(), hash);
  return b2aToHex(hash, SHA256_DIGEST_LENGTH);
}

std::string utils::crypto::hmacSha256(std::string const& input, std::string const& key)
{
  unsigned char hash[SHA256_DIGEST_LENGTH];

  unsigned int len;

  HMAC(EVP_sha256(),
       key.c_str(),
       int(key.length()),
       reinterpret_cast<const unsigned char*>(input.c_str()),
       input.size(),
       hash,
       &len);
  return b2aToHex(hash, SHA256_DIGEST_LENGTH);
}
