// script_2b79931b08683e0a  (2B79931B08683E0A.gscc) (size: 14759 Bytes / 0x39a7 / GSC)
// magic .... 0xa0d4353478b vm: Call of Duty: Modern Warfare III (8B) (PC)
// crc: 0xa325beb1 (2737159857)
// size ...... 10278 < 14759
// after cleanup, we have about ~4500 bytes

#using scripts\common\utility;
#using scripts\engine\utility;

#namespace namespace_152f3860b54f75e5;

// TODO
function yay()
{
    iprintln("WOW!");
}

/*

    IW8 says this is scripts/anim/utility_common.gsc
    it contains lots of unused utilities, which we can stuff here
    for many many things. everything below is used

*/

function function_3b5ee84f9c79735a()
{
    return !function_c8faefa04f41c504( self.var_e573dcdfaed7ad ) && function_f904d69cad962f64( self.var_e573dcdfaed7ad ) && function_4913aba743f96247( self.var_e573dcdfaed7ad ) == "spread";
}

function function_d8235e7edba68a91( var_e573dcdfaed7ad )
{
    return function_4913aba743f96247( var_e573dcdfaed7ad ) == "spread";
}

// i think its used tbh...
function function_f6c41425054da4ec()
{
    return function_4913aba743f96247( self.var_e573dcdfaed7ad ) == "pistol";
}

function function_ce1bfddfdc64b503()
{
    return function_4913aba743f96247( self.var_e573dcdfaed7ad ) == "rocketlauncher";
}

function function_57e61f64bbaae54c()
{
    bruh = function_4913aba743f96247( self.var_e573dcdfaed7ad );
    
    switch ( bruh )
    {
        case #"hash_690c0d6a821b42e":
        case #"hash_6191aaef9f922f96":
        case #"hash_8cdaf2e4ecfe5b51":
        case #"hash_900cb96c552c5e8e":
        case #"hash_fa24dff6bd60a12d":
            return true;
    }
    
    return false;
}

function function_aecb54d54d1ceb07()
{
    return self.var_e573dcdfaed7ad == self.var_5b2c0c714394a9d1 && !function_c8faefa04f41c504( self.var_e573dcdfaed7ad );
}

function function_68ad9919a5d31b12()
{
    return self.var_e573dcdfaed7ad == self.var_93dc75e5ee4c380c && !function_c8faefa04f41c504( self.var_e573dcdfaed7ad );
}

function function_bbfab76a84a7751b( var_9bc9d0ee2a8a46f5 )
{
    if ( !isdefined( var_9bc9d0ee2a8a46f5 ) )
    {
        var_9bc9d0ee2a8a46f5 = 1;
    }
    
    [[ anim.var_e780314d3c4bbea ]]( var_9bc9d0ee2a8a46f5 );
}

function function_d9759c07e0c62ecc( enemy )
{
    if ( !isdefined( enemy ) )
    {
        enemy = self.enemy;
    }
    
    if ( isdefined( enemy ) )
    {
        self.a.var_a01eb93f3efb5c3b = enemy function_e4f23d15b994114b();
        self.a.var_4e12067979220222 = function_9b7ff7ef73c3451a();
        return self.a.var_a01eb93f3efb5c3b;
    }
    
    if ( isdefined( self.a.var_4e12067979220222 ) && isdefined( self.a.var_a01eb93f3efb5c3b ) && self.a.var_4e12067979220222 + 3000 < function_9b7ff7ef73c3451a() )
    {
        return self.a.var_a01eb93f3efb5c3b;
    }
    
    var_de6ccb958be4546e = self function_e4f23d15b994114b();
    var_de6ccb958be4546e += 196 * self.var_7358f2fec06ff9f7;
    return var_de6ccb958be4546e;
}

// weirdly used combo here
function function_ba9b49db210d7def( var_a1ee865c37425cb9 )
{
    if ( !isdefined( var_a1ee865c37425cb9 ) )
    {
        return ( 0, 0, 0 );
    }
    
    if ( !isdefined( var_a1ee865c37425cb9.var_fe0696d9966d2993 ) )
    {
        return var_a1ee865c37425cb9.angles;
    }
    
    var_f4b64b2e64700883 = var_a1ee865c37425cb9.angles;
    var_5190f3ffc6e0ccde = function_55e9029216ea81ce( var_f4b64b2e64700883[ 0 ] + var_a1ee865c37425cb9.var_fe0696d9966d2993[ 0 ] );
    var_5190f4ffc6e0cf11 = var_f4b64b2e64700883[ 1 ];
    var_5190f1ffc6e0c878 = function_55e9029216ea81ce( var_f4b64b2e64700883[ 2 ] + var_a1ee865c37425cb9.var_fe0696d9966d2993[ 2 ] );
    return ( var_5190f3ffc6e0ccde, var_5190f4ffc6e0cf11, var_5190f1ffc6e0c878 );
}

function function_c72ddb3df014334d( var_542384043461f72d )
{
    function_d353703eb7e16967( !function_df0ba9977af06ac8() );
    
    if ( isdefined( self.type ) && function_c9035978603f3d5e( self ) )
    {
        var_9cfe111ea9df5b56 = function_ba9b49db210d7def( self );
        forward = function_6343041d48c52fd1( var_9cfe111ea9df5b56 );
        var_9288e19c8dd51644 = function_705826e39eda649e( forward, var_542384043461f72d - self.origin, var_9cfe111ea9df5b56[ 2 ] * -1 );
        var_9288e19c8dd51644 += self.origin;
        var_1426ee03498675e4 = function_2e9801b8b851699e( var_9288e19c8dd51644 ) - var_9cfe111ea9df5b56[ 1 ];
        var_1426ee03498675e4 = function_55e9029216ea81ce( var_1426ee03498675e4 );
        return var_1426ee03498675e4;
    }
    
    var_1426ee03498675e4 = function_2e9801b8b851699e( var_542384043461f72d ) - self.angles[ 1 ];
    var_1426ee03498675e4 = function_55e9029216ea81ce( var_1426ee03498675e4 );
    return var_1426ee03498675e4;
}

function function_6629252d5d8d6296( var_76ebdb469636b6ad, var_a1ee865c37425cb9 )
{
    var_1426ee03498675e4 = var_a1ee865c37425cb9 function_c72ddb3df014334d( var_76ebdb469636b6ad );
    
    if ( var_1426ee03498675e4 > 60 || var_1426ee03498675e4 < -60 )
    {
        return false;
    }
    
    if ( function_c182c92dbea4f945( var_a1ee865c37425cb9 ) && var_1426ee03498675e4 < -14 )
    {
        return false;
    }
    
    if ( function_8a536e06889acede( var_a1ee865c37425cb9 ) && var_1426ee03498675e4 > 12 )
    {
        return false;
    }
    
    return true;
}

function function_4f88f0dc0f0ef0e0( var_a1ee865c37425cb9 )
{
    if ( isdefined( var_a1ee865c37425cb9.var_62dfa801f1bc110e ) )
    {
        return var_a1ee865c37425cb9.var_62dfa801f1bc110e;
    }
    
    var_98a93aa48845f87b = ( -26, 0.4, 36 );
    var_6e1f1f062bc22c53 = ( -32, 7, 63 );
    var_55540b47802ce192 = ( 43.5, 11, 36 );
    var_21918bbf1c0e7180 = ( 36, 8.3, 63 );
    var_72245f24cad31cd3 = ( 3.5, -12.5, 45 );
    var_cba036d32a0ccd0b = ( -3.7, -22, 63 );
    var_ed4a2a73f94d1ab5 = ( 0, 30, 13 );
    var_c9548ee0484f7c10 = 0;
    var_b3e742ac78b00246 = ( 0, 0, 0 );
    axis = function_3b788ddf6ca7f51d( var_a1ee865c37425cb9.angles );
    right = axis[ "right" ];
    forward = axis[ "forward" ];
    up = axis[ "up" ];
    var_1915e77120006531 = var_a1ee865c37425cb9.type;
    
    switch ( var_1915e77120006531 )
    {
        case #"hash_e1d8e1adebed5a61":
            var_bd986ff07780228f = var_a1ee865c37425cb9 function_1d0e7756376929();
            
            if ( !isdefined( var_bd986ff07780228f ) || var_bd986ff07780228f == "crouch" )
            {
                var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_98a93aa48845f87b );
            }
            else
            {
                var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_6e1f1f062bc22c53 );
            }
            
            break;
        case #"hash_cd3ffe799551db82":
            var_bd986ff07780228f = var_a1ee865c37425cb9 function_1d0e7756376929();
            
            if ( !isdefined( var_bd986ff07780228f ) || var_bd986ff07780228f == "crouch" )
            {
                var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_55540b47802ce192 );
            }
            else
            {
                var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_21918bbf1c0e7180 );
            }
            
            break;
        case #"hash_410b602cd708b472":
        case #"hash_78b110033ccb68b0":
        case #"hash_805ed2ec27b468f7":
        case #"hash_bdacbb6eaaa538c7":
            var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_cba036d32a0ccd0b );
            break;
        case #"hash_2c4ea8d9cb1d214":
        case #"hash_776752872754e5ee":
        case #"hash_c3b74422dec48736":
            var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_72245f24cad31cd3 );
            break;
        case #"hash_b786e406d37a0dd7":
            var_b3e742ac78b00246 = function_828301c69aec78ba( var_a1ee865c37425cb9 );
            break;
        case #"hash_c051a32186a33cae":
            var_b3e742ac78b00246 = function_a4587b1ff4fbd718( right, forward, up, var_ed4a2a73f94d1ab5 );
            break;
    }
    
    var_a1ee865c37425cb9.var_62dfa801f1bc110e = var_b3e742ac78b00246;
    return var_a1ee865c37425cb9.var_62dfa801f1bc110e;
}

function function_828301c69aec78ba( var_a1ee865c37425cb9, var_55f2a89ea445dd80 )
{
    function_d353703eb7e16967( isdefined( var_a1ee865c37425cb9 ) && var_a1ee865c37425cb9.type == "<dev string:x1c>" );
    var_d9091e7beb7128e8 = ( 2, -10, 35 );
    var_6314194b648994a8 = ( -19, -10, 32 );
    var_4ca040109b9f8c1d = ( 16, -10, 32 );
    right = function_f3142d73646911d6( var_a1ee865c37425cb9.angles );
    forward = function_6343041d48c52fd1( var_a1ee865c37425cb9.angles );
    up = function_e1cbcab0b57b6631( var_a1ee865c37425cb9.angles );
    var_62dfa801f1bc110e = var_d9091e7beb7128e8;
    
    if ( isdefined( var_55f2a89ea445dd80 ) )
    {
        if ( var_55f2a89ea445dd80 == "left" )
        {
            var_62dfa801f1bc110e = var_6314194b648994a8;
        }
        else if ( var_55f2a89ea445dd80 == "right" )
        {
            var_62dfa801f1bc110e = var_4ca040109b9f8c1d;
        }
        else
        {
            function_4afbe349a074b850( "<dev string:x28>" );
        }
    }
    
    return function_a4587b1ff4fbd718( right, forward, up, var_62dfa801f1bc110e );
}

function function_a4587b1ff4fbd718( right, forward, up, var_7d0d6b39d96165c7 )
{
    return right * var_7d0d6b39d96165c7[ 0 ] + forward * var_7d0d6b39d96165c7[ 1 ] + up * var_7d0d6b39d96165c7[ 2 ];
}

/#

    // Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
    // Params 2
    // Checksum 0x0, Offset: 0x1630
    // Size: 0x4c, Type: dev
    function function_a8baa7c6d9548a39( var_9faddc46c7efb603, end )
    {
        self endon( "<dev string:x37>" );
        level notify( "<dev string:x40>" );
        level endon( "<dev string:x40>" );
        
        for ( ;; )
        {
            function_ee91882b850c954b( var_9faddc46c7efb603, end, ( 0.3, 1, 0 ), 1 );
            wait 0.05;
        }
    }

#/

function function_4bb6914df8dd65d8()
{
    var_64f88d0441939203 = function_9b7ff7ef73c3451a();
    var_a1ee865c37425cb9 = self.var_a1ee865c37425cb9;
    enemy = self.enemy;
    var_a53e0a65b825db1d = !isdefined( self.var_c98e9008b1b17f09 ) || var_64f88d0441939203 >= self.var_c98e9008b1b17f09;
    
    if ( var_a53e0a65b825db1d || !function_6ec37fbad41e108e( self.var_c07e2ed36098c414, enemy ) || !function_6ec37fbad41e108e( self.var_1f088108efc5d0c4, var_a1ee865c37425cb9 ) )
    {
        self.var_4bb6914df8dd65d8 = function_e28d706f2d3f4c65( enemy, var_a1ee865c37425cb9 );
        self.var_c98e9008b1b17f09 = var_64f88d0441939203 + 1000;
        self.var_1f088108efc5d0c4 = var_a1ee865c37425cb9;
        self.var_c07e2ed36098c414 = enemy;
    }
    
    var_be5ab6ec28083880 = self.var_4bb6914df8dd65d8;
    
    if ( !var_be5ab6ec28083880 )
    {
        /#
            if ( self function_834d6e34d701302d() == function_fbdb5fd2ac2902f( @"hash_c407a6f2012f4956" ) )
            {
                thread function_a8baa7c6d9548a39( var_a1ee865c37425cb9.origin + function_4f88f0dc0f0ef0e0( var_a1ee865c37425cb9 ), function_d9759c07e0c62ecc() );
            }
        #/
    }
    
    return var_be5ab6ec28083880;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 2, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x179d
// Size: 0xac
function function_e28d706f2d3f4c65( enemy, var_a1ee865c37425cb9 )
{
    if ( !isdefined( enemy ) )
    {
        return 0;
    }
    
    if ( !isdefined( var_a1ee865c37425cb9 ) )
    {
        var_be5ab6ec28083880 = self function_8bdd8cc548397384( enemy );
    }
    else
    {
        var_a2825de7e3791a80 = undefined;
        
        if ( function_67ff0340e1c92259( enemy ) )
        {
            var_a2825de7e3791a80 = enemy function_54012304a10181d6();
        }
        else
        {
            var_a2825de7e3791a80 = function_d9759c07e0c62ecc( enemy );
        }
        
        if ( function_df0ba9977af06ac8() && function_c9035978603f3d5e( var_a1ee865c37425cb9 ) )
        {
            var_be5ab6ec28083880 = function_a76836ca0f1172ab( enemy, var_a2825de7e3791a80, var_a1ee865c37425cb9 );
            
            if ( !var_be5ab6ec28083880 )
            {
                var_a2825de7e3791a80 = ( enemy.origin + var_a2825de7e3791a80 ) / 2;
                var_be5ab6ec28083880 = function_a76836ca0f1172ab( enemy, var_a2825de7e3791a80, var_a1ee865c37425cb9 );
            }
        }
        else
        {
            var_be5ab6ec28083880 = function_a76836ca0f1172ab( enemy, var_a2825de7e3791a80, var_a1ee865c37425cb9 );
        }
    }
    
    return var_be5ab6ec28083880;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 3, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1852
// Size: 0xb4
function function_a76836ca0f1172ab( enemy, var_76ebdb469636b6ad, var_a1ee865c37425cb9 )
{
    if ( function_c182c92dbea4f945( var_a1ee865c37425cb9 ) || function_8a536e06889acede( var_a1ee865c37425cb9 ) )
    {
        if ( !function_6629252d5d8d6296( var_76ebdb469636b6ad, var_a1ee865c37425cb9 ) )
        {
            return 0;
        }
    }
    
    var_b3e742ac78b00246 = function_4f88f0dc0f0ef0e0( var_a1ee865c37425cb9 );
    var_62c5ee69c494a850 = var_a1ee865c37425cb9.origin + var_b3e742ac78b00246;
    
    if ( !function_1c3b1fcf5891490b( var_62c5ee69c494a850, var_76ebdb469636b6ad, var_a1ee865c37425cb9 ) )
    {
        return 0;
    }
    
    if ( !function_4a758fc1e9807763( var_62c5ee69c494a850, var_76ebdb469636b6ad, 0, enemy ) )
    {
        if ( function_c4f17335e22375ca( var_a1ee865c37425cb9 ) )
        {
            var_62c5ee69c494a850 = ( 0, 0, 64 ) + var_a1ee865c37425cb9.origin;
            return function_4a758fc1e9807763( var_62c5ee69c494a850, var_76ebdb469636b6ad, 0, enemy );
        }
        
        return 0;
    }
    
    return 1;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 3, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x190f
// Size: 0xf4, Type: bool
function function_1c3b1fcf5891490b( var_8f78581cd3208c45, var_ea13048ae45874c6, var_de077e6e46369528 )
{
    var_ddb680f3984c4777 = self.var_b73bf0931ea0a5cc - anim.var_3b1a9f2944d455a6;
    var_a5337f8300110201 = self.var_90b2566c33bab911 + anim.var_3b1a9f2944d455a6;
    var_cac6b8b7efddb0e4 = var_ea13048ae45874c6 - var_8f78581cd3208c45;
    
    if ( function_df0ba9977af06ac8() )
    {
        if ( isdefined( var_de077e6e46369528 ) && function_c9035978603f3d5e( var_de077e6e46369528 ) )
        {
            angles = var_de077e6e46369528.angles;
        }
        else
        {
            angles = self.angles;
        }
        
        var_cac6b8b7efddb0e4 = function_4f240df91a3aea90( var_cac6b8b7efddb0e4, angles );
    }
    
    var_e9e676154471f7ed = function_55e9029216ea81ce( function_3da89cb6fda9bd4f( var_cac6b8b7efddb0e4 ) );
    
    if ( var_e9e676154471f7ed < var_ddb680f3984c4777 )
    {
        return false;
    }
    
    if ( var_e9e676154471f7ed > var_a5337f8300110201 )
    {
        if ( isdefined( var_de077e6e46369528 ) && !function_c4f17335e22375ca( var_de077e6e46369528 ) )
        {
            return false;
        }
        
        if ( var_e9e676154471f7ed > anim.var_3202ed74e2fe0ebc + var_a5337f8300110201 )
        {
            return false;
        }
    }
    
    return true;
}

/#

    // Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
    // Params 0
    // Checksum 0x0, Offset: 0x1a0c
    // Size: 0x10, Type: dev
    function function_ef0af81ee1da0a4c()
    {
        function_4afbe349a074b850( "<dev string:x50>" );
    }

#/

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1a24
// Size: 0x9c
function function_a2053e36e133f4be()
{
    if ( !function_176838b54e058ec4() || self.var_af345d32838f2f44 )
    {
        self.var_f1bee346a446e863 = undefined;
        return 0;
    }
    
    var_981e36835eec56c4 = istrue( self.var_51642e27c7e7d224 );
    
    if ( !function_3bba92c48cdb30ec( self.enemy ) )
    {
        if ( !var_981e36835eec56c4 || self.var_aeddcfd92135b15d )
        {
            return function_d815b8cbe7fcc8d2();
        }
    }
    
    if ( var_981e36835eec56c4 )
    {
        return 0;
    }
    
    if ( !function_1c3b1fcf5891490b( self function_c42cbb7e36e1bdc(), self.var_6842fd253438c712 ) )
    {
        return 0;
    }
    
    var_2ac23f64117a2050 = self function_54012304a10181d6();
    return function_d683f48ec999f68( var_2ac23f64117a2050 );
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1ac9
// Size: 0x47, Type: bool
function function_176838b54e058ec4()
{
    if ( !isdefined( self.enemy ) )
    {
        return false;
    }
    
    if ( !isdefined( self.var_6842fd253438c712 ) )
    {
        return false;
    }
    
    if ( !self function_2044642e85837dd4() )
    {
        return false;
    }
    
    if ( !isdefined( self.var_f1bee346a446e863 ) && !function_3270f150e91de3cb() )
    {
        return false;
    }
    
    return true;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1b19
// Size: 0xbe, Type: bool
function function_d815b8cbe7fcc8d2()
{
    if ( !self function_9e3be62d3ec96fb7() && !istrue( self.var_aeddcfd92135b15d ) )
    {
        return false;
    }
    
    var_e6f2f2bcc9008196 = undefined;
    
    if ( isdefined( self.enemy.var_9949d18c1ca92648 ) )
    {
        var_b3e742ac78b00246 = function_4f88f0dc0f0ef0e0( self.enemy.var_9949d18c1ca92648 );
        var_e6f2f2bcc9008196 = self.enemy.var_9949d18c1ca92648.origin + var_b3e742ac78b00246;
    }
    else
    {
        var_e6f2f2bcc9008196 = self.enemy function_e4f23d15b994114b();
    }
    
    if ( !self function_6c1135dcb6bb5b9c( var_e6f2f2bcc9008196 ) && !istrue( self.var_aeddcfd92135b15d ) )
    {
        return false;
    }
    
    self.var_f1bee346a446e863 = var_e6f2f2bcc9008196;
    return true;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 1, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1be0
// Size: 0x74
function function_78608aa3fcc26a06( var_76ebdb469636b6ad )
{
    if ( isdefined( self.a.var_aeb62b5cec8b1d71 ) && function_63d4e8dccbb9c2b7( self.a.var_aeb62b5cec8b1d71[ "right" ] ) )
    {
        return 0;
    }
    
    if ( !function_4a758fc1e9807763( self function_e4f23d15b994114b(), var_76ebdb469636b6ad, 0, undefined ) )
    {
        return 0;
    }
    
    var_528cdf0816c4001d = self function_54012304a10181d6();
    return function_4a758fc1e9807763( var_528cdf0816c4001d, var_76ebdb469636b6ad, 0, undefined );
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1c5d
// Size: 0x6e, Type: bool
function function_3270f150e91de3cb()
{
    if ( isdefined( self.var_f1bee346a446e863 ) && !function_78608aa3fcc26a06( self.var_f1bee346a446e863 ) )
    {
        return true;
    }
    
    return !isdefined( self.var_83c4f360c745e66f ) || function_62d746fee72d9b( self.var_83c4f360c745e66f, self.var_6842fd253438c712 ) > 256 || function_62d746fee72d9b( self.var_998e5d645632e1ce, self.origin ) > 1024;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 1, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1cd4
// Size: 0x152, Type: bool
function function_d683f48ec999f68( var_2ac23f64117a2050 )
{
    var_bc4d272afc4e79e6 = function_367c0b041e698cab( self.enemy.var_9980f85b6b543e65, 1024 );
    
    if ( isdefined( self.enemy ) && function_62d746fee72d9b( self.origin, self.enemy.origin ) > function_be17571b6af76ad2( var_bc4d272afc4e79e6 + 768 ) )
    {
        self.var_f1bee346a446e863 = undefined;
        return false;
    }
    
    if ( function_3270f150e91de3cb() )
    {
        self.var_998e5d645632e1ce = self.origin;
        self.var_83c4f360c745e66f = self.var_6842fd253438c712;
        
        if ( istrue( self.var_fcfc4be81d62a08b ) )
        {
            self.var_f1bee346a446e863 = self.var_6842fd253438c712;
            return true;
        }
        
        var_bdcf463e5b27a0b8 = function_d9759c07e0c62ecc();
        self.var_f1bee346a446e863 = self function_ae20ba1c641567dd( var_2ac23f64117a2050, var_bdcf463e5b27a0b8, self.var_26f2abc510258097 );
        return isdefined( self.var_f1bee346a446e863 );
    }
    else if ( isdefined( self.var_f1bee346a446e863 ) && isdefined( self.var_80a58580f25aff29 ) && function_62d746fee72d9b( self.origin, self.var_f1bee346a446e863 ) < 1024 )
    {
        self.var_f1bee346a446e863 = undefined;
    }
    
    return isdefined( self.var_f1bee346a446e863 );
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 1, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1e2f
// Size: 0x69, Type: bool
function function_19216375fc7fa198( var_e6749c0530f0d0f1 )
{
    if ( !isdefined( self.enemy ) )
    {
        return false;
    }
    
    if ( isdefined( var_e6749c0530f0d0f1 ) && self function_8bdd8cc548397384( self.enemy, var_e6749c0530f0d0f1 ) || self function_8bdd8cc548397384( self.enemy ) )
    {
        if ( !function_1c3b1fcf5891490b( self function_c42cbb7e36e1bdc(), self.enemy function_e4f23d15b994114b() ) )
        {
            return false;
        }
        
        return true;
    }
    
    return false;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 1, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1ea1
// Size: 0x36, Type: bool
function function_2182b1bbea9371ea( var_455bc5f6c5816328 )
{
    if ( !isdefined( var_455bc5f6c5816328 ) )
    {
        var_455bc5f6c5816328 = 5;
    }
    
    return isdefined( self.enemy ) && self function_9ffd73625b3646d0( self.enemy, var_455bc5f6c5816328 );
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0, eflags: 0x2 linked
// Checksum 0x0, Offset: 0x1ee0
// Size: 0x2f
function function_b19b397d142f0192()
{
    if ( self.var_3b3475845dc258f7 )
    {
        return 1;
    }
    
    if ( self.var_b45139397db75205 <= self.var_3ea227cf5c187d9f )
    {
        return 0;
    }
    
    return self function_24a0d5cf0c69f123();
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0
// Checksum 0x0, Offset: 0x1f18
// Size: 0xd8, Type: bool
function function_f0193dd0c1e923e4()
{
    if ( !isdefined( self.enemy ) )
    {
        return false;
    }
    
    if ( self.enemy function_2df6b32dfef65e34() )
    {
        return true;
    }
    
    if ( function_3bba92c48cdb30ec( self.enemy ) )
    {
        if ( isdefined( self.enemy.var_6d8dd03997c19383 ) && self.enemy.var_6d8dd03997c19383 < self.enemy.var_c102b6aca1c7cedf )
        {
            return true;
        }
    }
    else if ( function_dff8b9b70d60d62b( self.enemy ) && self.enemy function_b19b397d142f0192() )
    {
        return true;
    }
    
    if ( isdefined( self.enemy.var_1da1da85fe03a260 ) && self.enemy.var_1da1da85fe03a260 )
    {
        return true;
    }
    
    return false;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 0
// Checksum 0x0, Offset: 0x1ff9
// Size: 0x25, Type: bool
function function_b5d00d1c84f5c6c8()
{
    function_d353703eb7e16967( isdefined( self ) );
    
    if ( !function_19216375fc7fa198() )
    {
        return false;
    }
    
    if ( !self function_8b63a7348687b370() )
    {
        return false;
    }
    
    return true;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 1
// Checksum 0x0, Offset: 0x2027
// Size: 0xcd
function function_8c5b4959225948a7( var_d4876c861b3d6be )
{
    var_28656d665cf2b0fa = [];
    
    foreach ( var_fc1386685eef5bfd in var_d4876c861b3d6be )
    {
        if ( var_fc1386685eef5bfd.var_992f3595f9b86265 <= 0 )
        {
            continue;
        }
        
        for ( i = 0; i < var_28656d665cf2b0fa.size ; i++ )
        {
            if ( var_fc1386685eef5bfd.var_992f3595f9b86265 < var_28656d665cf2b0fa[ i ].var_992f3595f9b86265 )
            {
                for ( j = var_28656d665cf2b0fa.size; j > i ; j-- )
                {
                    var_28656d665cf2b0fa[ j ] = var_28656d665cf2b0fa[ j - 1 ];
                }
                
                break;
            }
        }
        
        var_28656d665cf2b0fa[ i ] = var_fc1386685eef5bfd;
    }
    
    return var_28656d665cf2b0fa;
}

// Namespace namespace_152f3860b54f75e5 / namespace_7843e1029b5c80e
// Params 3
// Checksum 0x0, Offset: 0x20fd
// Size: 0x17d
function function_2233281901186e0c( player, ai, var_3cb4c8ad9080088d )
{
    var_d26e2f991f696ec7 = function_9b7ff7ef73c3451a();
    
    if ( !isdefined( var_3cb4c8ad9080088d ) )
    {
        var_3cb4c8ad9080088d = 0;
    }
    
    if ( isdefined( ai.var_a6050f3585904a23 ) && ai.var_a6050f3585904a23 + var_3cb4c8ad9080088d >= var_d26e2f991f696ec7 )
    {
        function_d353703eb7e16967( isdefined( ai.var_2e9aede5cd7d3cc2 ) );
        return ai.var_2e9aede5cd7d3cc2;
    }
    
    ai.var_a6050f3585904a23 = var_d26e2f991f696ec7;
    
    if ( !function_7c6851912dd3dc82( player.origin, player.angles, ai.origin, 0.766 ) )
    {
        ai.var_2e9aede5cd7d3cc2 = 0;
        return 0;
    }
    
    var_d539dd4d949070d9 = player function_c42cbb7e36e1bdc();
    var_8588ce8cb050baf3 = ai.origin;
    
    if ( function_4a758fc1e9807763( var_d539dd4d949070d9, var_8588ce8cb050baf3, 1, player, ai ) )
    {
        ai.var_2e9aede5cd7d3cc2 = 1;
        return 1;
    }
    
    var_18718f98529a77d8 = ai function_54012304a10181d6();
    
    if ( function_4a758fc1e9807763( var_d539dd4d949070d9, var_18718f98529a77d8, 1, player, ai ) )
    {
        ai.var_2e9aede5cd7d3cc2 = 1;
        return 1;
    }
    
    var_59a0ba7c30f92d0b = ( var_18718f98529a77d8 + var_8588ce8cb050baf3 ) * 0.5;
    
    if ( function_4a758fc1e9807763( var_d539dd4d949070d9, var_59a0ba7c30f92d0b, 1, player, ai ) )
    {
        ai.var_2e9aede5cd7d3cc2 = 1;
        return 1;
    }
    
    ai.var_2e9aede5cd7d3cc2 = 0;
    return 0;
}
