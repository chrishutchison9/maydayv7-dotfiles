## Modrinth Server Mods
# name, id, url, hash - Attribute, Project ID/slug, Download URL, SRI hash
# require - Included only when the server option is set [Optional]
{
  fabric = {
    version = "26.1.2";
    mods = [
      # Server
      {
        name = "FabricAPI";
        id = "P7dR8mSH";
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/NqRnXk9x/fabric-api-0.152.1%2B26.1.2.jar";
        hash = "sha256-slrZJsj9EH0hs6l1Gpjat4dzZSOzmke8LMsEiWJoDXY=";
      }
      {
        name = "Lithium";
        id = "gvQqBUqZ";
        url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/fQBdPR1m/lithium-fabric-0.24.6%2Bmc26.1.2.jar";
        hash = "sha256-UJ5/dwx9SL036VkpFzKdsnaORpXHKkPiLBnvZND5g58=";
      }
      {
        name = "Krypton";
        id = "fQEb0iXm";
        url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/kYAGItyj/krypton-0.3.0.jar";
        hash = "sha256-dFsRFgQ0dC1EQFRqp+RF0U1ZuhJG5br5kdKTGQuplGM=";
      }
      {
        name = "FerriteCore";
        id = "uXXizFIs";
        url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
        hash = "sha256-ITlmxy7ZZ6zHOSvrKKhm+6MB/1a5l2wueAHC233mvyI=";
      }
      {
        name = "ScalableLux";
        id = "Ps1zyz6x";
        url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/gYbHVCz8/ScalableLux-0.2.0%2Bfabric.2b63825-all.jar";
        hash = "sha256-bamBsryRWGU1zjuw+kGXWonMRgO5w6EG0kMaIUF7HfA=";
      }
      {
        name = "C2ME";
        id = "VSNURh3q";
        url = "https://cdn.modrinth.com/data/VSNURh3q/versions/v1RNsfu7/c2me-fabric-mc26.1.2-0.4.0-alpha.0.17.jar";
        hash = "sha256-W6hKW/dASyp+A9yT85luhMTg9fF59GTeYoVdRLM6Dx8=";
      }
      {
        name = "PlayerRoles";
        id = "Rt1mrUHm";
        url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/sUiL9n9i/player-roles-1.9.0.jar";
        hash = "sha256-0q6WzsxFdOqrslFmH8C5Si9fADgOShnBhWa4SMcBY/8=";
      }
      {
        name = "SkinRestorer";
        id = "ghrZDhGW";
        url = "https://cdn.modrinth.com/data/ghrZDhGW/versions/rgcYRGDt/skinrestorer-2.8.1%2B26.1-fabric.jar";
        hash = "sha256-MazpunDTQeMBLN3Da1t5akwBBXH+ia733loqgA4Ft38=";
      }
      {
        name = "Silk";
        id = "aTaCgKLW";
        url = "https://cdn.modrinth.com/data/aTaCgKLW/versions/dm3Sfg3x/silk-all-1.11.8.jar";
        hash = "sha256-4+u68yBi4nom7b96+PCuJvwpAnQHgtgByjTxYaF5gpM=";
      }
      {
        name = "FabricKotlin";
        id = "Ha28R6CL";
        url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/Pd0xrHCw/fabric-language-kotlin-1.13.12%2Bkotlin.2.4.0.jar";
        hash = "sha256-NsXdi3KONHDSiCrmMRm5OiBQD8Dqb1yUXBK/ZbWrGDI=";
      }
      {
        name = "Veinminer";
        id = "OhduvhIc";
        url = "https://cdn.modrinth.com/data/OhduvhIc/versions/h4Z7xAL0/veinminer-fabric-2.10.3.jar";
        hash = "sha256-/Q4M4yr/kjAMtuSyBeVbgSBMmNoCWrB4tStHSUdUSVk=";
      }
      {
        name = "VeinminerEnchant";
        id = "4sP0LXxp";
        url = "https://cdn.modrinth.com/data/4sP0LXxp/versions/6zzsM770/veinminer-enchant-2.10.3.jar";
        hash = "sha256-/li1ve6r0w9Mha+9tPO0Vf5mWafQghUpFzZDSEVcivs=";
      }

      # Client and Server
      {
        name = "Jade";
        id = "nvQzSEkH";
        url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/zu6GcgEW/Jade-mc26.1-Fabric-26.1.6.jar";
        hash = "sha256-X+1RyaOSVWNyLWRGTKSJErPRYci1XFJVdcbt/rsphS8=";
      }
      {
        name = "SimpleVC";
        id = "9eGKb6K1";
        url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/xmAicr0J/voicechat-fabric-2.6.19%2B26.1.2.jar";
        hash = "sha256-JsPgZqSfRb70Z00m0FN2/noc8Tm4++ncOLt0r0Z0rdQ=";
        require = "vc-port";
      }
    ];
  };
}
