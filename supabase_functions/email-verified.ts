import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // This function handles the redirect after email verification
    // It shows a success page that can be displayed in a browser
    
    const html = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verified - SmallVendors</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
            
            .container {
                background: white;
                border-radius: 16px;
                padding: 40px;
                text-align: center;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                max-width: 500px;
                width: 100%;
            }
            
            .success-icon {
                width: 80px;
                height: 80px;
                background: #10b981;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 24px;
                animation: bounce 0.6s ease-out;
            }
            
            .checkmark {
                width: 40px;
                height: 40px;
                stroke: white;
                stroke-width: 3;
                fill: none;
                stroke-linecap: round;
                stroke-linejoin: round;
            }
            
            h1 {
                color: #1f2937;
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 16px;
            }
            
            p {
                color: #6b7280;
                font-size: 16px;
                line-height: 1.6;
                margin-bottom: 32px;
            }
            
            .app-info {
                background: #f9fafb;
                border-radius: 12px;
                padding: 24px;
                margin-bottom: 24px;
            }
            
            .app-info h3 {
                color: #2563eb;
                font-size: 18px;
                margin-bottom: 8px;
            }
            
            .app-info p {
                margin: 0;
                font-size: 14px;
            }
            
            .close-button {
                background: #2563eb;
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: background-color 0.2s;
            }
            
            .close-button:hover {
                background: #1d4ed8;
            }
            
            @keyframes bounce {
                0%, 20%, 53%, 80%, 100% {
                    transform: translate3d(0,0,0);
                }
                40%, 43% {
                    transform: translate3d(0,-20px,0);
                }
                70% {
                    transform: translate3d(0,-10px,0);
                }
                90% {
                    transform: translate3d(0,-4px,0);
                }
            }
            
            @media (max-width: 480px) {
                .container {
                    padding: 24px;
                }
                
                h1 {
                    font-size: 24px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="success-icon">
                <svg class="checkmark" viewBox="0 0 24 24">
                    <path d="M20 6L9 17l-5-5"/>
                </svg>
            </div>
            
            <h1>Email Verified Successfully!</h1>
            <p>Your email address has been verified. You can now return to the SmallVendors app to complete your profile setup.</p>
            
            <div class="app-info">
                <h3>Next Steps:</h3>
                <p>1. Return to the SmallVendors app<br>
                2. Tap "I've Verified My Email"<br>
                3. Complete your profile setup</p>
            </div>
            
            <button class="close-button" onclick="window.close()">
                Close This Window
            </button>
        </div>
        
        <script>
            // Auto-close after 5 seconds if possible
            setTimeout(() => {
                try {
                    window.close();
                } catch (e) {
                    // Window close might be blocked by browser
                }
            }, 5000);
        </script>
    </body>
    </html>
    `

    return new Response(html, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/html; charset=utf-8',
      },
    })

  } catch (error) {
    console.error('Error:', error)
    
    const errorHtml = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verification Error - SmallVendors</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: #f5f5f5;
            }
            .error-container {
                background: white;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                max-width: 400px;
                margin: 0 auto;
            }
            .error-icon {
                color: #ef4444;
                font-size: 48px;
                margin-bottom: 20px;
            }
            h1 {
                color: #1f2937;
                margin-bottom: 16px;
            }
            p {
                color: #6b7280;
            }
        </style>
    </head>
    <body>
        <div class="error-container">
            <div class="error-icon">⚠️</div>
            <h1>Verification Error</h1>
            <p>There was an issue with email verification. Please try again or contact support.</p>
        </div>
    </body>
    </html>
    `
    
    return new Response(errorHtml, {
      status: 500,
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/html; charset=utf-8',
      },
    })
  }
})