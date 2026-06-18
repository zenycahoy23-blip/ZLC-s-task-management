<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['message' => 'Task Management System API'];
});
