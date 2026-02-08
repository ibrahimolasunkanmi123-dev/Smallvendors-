import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, type = 'signup' } = await req.json()
    
    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate 6-digit verification code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString()
    
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Store verification code in database with expiry (10 minutes)
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString()
    
    const { error: dbError } = await supabase
      .from('email_verification_codes')
      .upsert({
        email,
        code: verificationCode,
        expires_at: expiresAt,
        used: false,
        type
      })

    if (dbError) {
      throw new Error(`Database error: ${dbError.message}`)
    }

    // Send email using Resend
    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    
    if (!resendApiKey) {
      throw new Error('Resend API key not configured')
    }

    const emailSubject = type === 'signup' ? 'Verify Your SmallVendors Account' : 'SmallVendors Verification Code'
    const emailContent = type === 'signup' 
      ? `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2563eb; margin: 0;">SmallVendors</h1>
            <p style="color: #6b7280; margin: 5px 0;">Welcome to the marketplace for small businesses</p>
          </div>
          
          <h2 style="color: #1f2937;">Verify Your Email Address</h2>
          <p>Hello,</p>
          <p>Thank you for signing up with SmallVendors! To complete your registration, please use the verification code below:</p>
          
          <div style="background: linear-gradient(135deg, #2563eb, #3b82f6); padding: 25px; text-align: center; margin: 30px 0; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
            <p style="color: white; margin: 0 0 10px 0; font-size: 14px;">Your verification code is:</p>
            <h1 style="color: white; font-size: 36px; margin: 0; letter-spacing: 6px; font-weight: bold;">${verificationCode}</h1>
          </div>
          
          <div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; border-radius: 4px;">
            <p style="margin: 0; color: #92400e;"><strong>Important:</strong> This code will expire in 10 minutes for security reasons.</p>
          </div>
          
          <p>Enter this code in the SmallVendors app to verify your email address and start exploring our marketplace.</p>
          
          <div style="margin: 30px 0; padding: 20px; background: #f9fafb; border-radius: 8px;">
            <h3 style="color: #1f2937; margin-top: 0;">What's next?</h3>
            <ul style="color: #4b5563; padding-left: 20px;">
              <li>Complete your profile setup</li>
              <li>Browse products from local vendors</li>
              <li>Start buying or selling in your area</li>
            </ul>
          </div>
          
          <p style="color: #6b7280; font-size: 14px;">If you didn't create an account with SmallVendors, please ignore this email.</p>
          
          <hr style="margin: 30px 0; border: none; border-top: 1px solid #e5e7eb;">
          <div style="text-align: center;">
            <p style="color: #6b7280; font-size: 12px; margin: 0;">
              SmallVendors Team<br>
              Connecting small businesses with local customers
            </p>
          </div>
        </div>
      `
      : `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2563eb; margin: 0;">SmallVendors</h1>
          </div>
          
          <h2 style="color: #1f2937;">Your Verification Code</h2>
          <p>Your verification code is:</p>
          
          <div style="background: #f3f4f6; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px;">
            <h1 style="color: #2563eb; font-size: 32px; margin: 0; letter-spacing: 4px;">${verificationCode}</h1>
          </div>
          
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
          
          <hr style="margin: 30px 0; border: none; border-top: 1px solid #e5e7eb;">
          <p style="color: #6b7280; font-size: 14px; text-align: center;">SmallVendors Team</p>
        </div>
      `

    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'SmallVendors <noreply@smallvendors.app>',
        to: [email],
        subject: emailSubject,
        html: emailContent,
      }),
    })

    if (!emailResponse.ok) {
      const errorText = await emailResponse.text()
      throw new Error(`Email service error: ${errorText}`)
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Verification code sent successfully',
        expiresIn: 600 // 10 minutes in seconds
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Internal server error' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})