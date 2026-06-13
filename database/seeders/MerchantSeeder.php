<?php

namespace Database\Seeders;

use App\Models\Merchant;
use Illuminate\Database\Seeder;

class MerchantSeeder extends Seeder
{
    public function run(): void
    {
        Merchant::create([
            'name' => 'Daraz',
            'code' => '001',
            'contact' => '01922002381',
            'address' => 'Miprur, Dhaka',
        ]);

        Merchant::create([
            'name' => 'Othoba',
            'code' => '002',
            'contact' => '01922002381',
            'address' => 'Miprur, Dhaka',
        ]);
    }
}