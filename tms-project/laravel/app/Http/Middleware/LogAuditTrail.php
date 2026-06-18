<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\AuditLog;

class LogAuditTrail
{
    /**
     * Handle an incoming request.
     *
     * @param \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response) $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Log API actions (excluding health checks and metrics)
        if ($request->user() && !in_array($request->path(), ['api/health', 'metrics'])) {
            $action = $request->method() . ' ' . $request->path();
            AuditLog::log(
                action: $action,
                description: json_encode($request->except(['password', 'token'])),
                userId: $request->user()->id,
                ipAddress: $request->ip()
            );
        }

        return $response;
    }
}
