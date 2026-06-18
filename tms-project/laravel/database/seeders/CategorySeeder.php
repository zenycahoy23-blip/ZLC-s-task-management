<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['category_name' => 'Development', 'description' => 'Development and coding tasks'],
            ['category_name' => 'Design', 'description' => 'UI/UX and design tasks'],
            ['category_name' => 'Testing', 'description' => 'Quality assurance and testing tasks'],
            ['category_name' => 'Documentation', 'description' => 'Documentation and writing tasks'],
            ['category_name' => 'DevOps', 'description' => 'Infrastructure and deployment tasks'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['category_name' => $category['category_name']], $category);
        }
    }
}
