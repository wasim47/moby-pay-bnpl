<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Mohammad Wasim',
            'email' => 'wasim.html@gmail.com',
            'password' => Hash::make('password'),
        ]);

        User::create([
            'name' => 'Moby Pay',
            'email' => 'admin@mmoby.my',
            'password' => Hash::make('password'),
        ]);
    }
}