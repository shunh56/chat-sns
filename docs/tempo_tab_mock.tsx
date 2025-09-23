/*
import React, { useState, useEffect } from 'react';

const TempoAppV5 = () => {
  const [activeTab, setActiveTab] = useState(0);
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [showMatchAnimation, setShowMatchAnimation] = useState(false);
  const [currentTime, setCurrentTime] = useState(new Date());
  const [breatheScale, setBreatheScale] = useState(1);
  
  // 洗練されたカラーシステム - Tempoの独自性を表現
  const colors = {
    // Primary Brand Colors - 温かみと信頼感
    primary: isDarkMode ? 'rgb(99, 102, 241)' : 'rgb(67, 56, 202)', // Indigo
    primaryLight: isDarkMode ? 'rgb(129, 140, 248)' : 'rgb(99, 102, 241)',
    secondary: isDarkMode ? 'rgb(236, 72, 153)' : 'rgb(219, 39, 119)', // Pink
    accent: isDarkMode ? 'rgb(245, 158, 11)' : 'rgb(217, 119, 6)', // Amber
    
    // Surface Colors - 奥行きと階層
    bg: isDarkMode ? 'rgb(15, 15, 23)' : 'rgb(250, 250, 252)', // 深い紫がかった背景
    surface: isDarkMode ? 'rgb(24, 24, 32)' : 'rgb(255, 255, 255)',
    surfaceElevated: isDarkMode ? 'rgb(31, 31, 40)' : 'rgb(248, 250, 252)',
    surfaceHover: isDarkMode ? 'rgb(37, 37, 48)' : 'rgb(241, 245, 249)',
    
    // Text Colors - 読みやすさと階層
    textPrimary: isDarkMode ? 'rgb(248, 250, 252)' : 'rgb(15, 23, 42)',
    textSecondary: isDarkMode ? 'rgb(148, 163, 184)' : 'rgb(100, 116, 139)',
    textTertiary: isDarkMode ? 'rgb(100, 116, 139)' : 'rgb(148, 163, 184)',
    
    // Status Colors - 感情と状態を表現
    success: isDarkMode ? 'rgb(34, 197, 94)' : 'rgb(22, 163, 74)',
    warning: isDarkMode ? 'rgb(251, 191, 36)' : 'rgb(245, 158, 11)',
    danger: isDarkMode ? 'rgb(239, 68, 68)' : 'rgb(220, 38, 38)',
    online: isDarkMode ? 'rgb(16, 185, 129)' : 'rgb(5, 150, 105)',
    
    // Gradient Definitions - ブランドの温かさを表現
    primaryGradient: isDarkMode 
      ? 'linear-gradient(135deg, rgb(99, 102, 241) 0%, rgb(168, 85, 247) 100%)'
      : 'linear-gradient(135deg, rgb(67, 56, 202) 0%, rgb(147, 51, 234) 100%)',
    warmGradient: isDarkMode
      ? 'linear-gradient(135deg, rgb(245, 158, 11) 0%, rgb(236, 72, 153) 100%)'
      : 'linear-gradient(135deg, rgb(217, 119, 6) 0%, rgb(219, 39, 119) 100%)',
    successGradient: isDarkMode
      ? 'linear-gradient(135deg, rgb(34, 197, 94) 0%, rgb(59, 130, 246) 100%)'
      : 'linear-gradient(135deg, rgb(22, 163, 74) 0%, rgb(37, 99, 235) 100%)',
  };

  // 呼吸するようなアニメーション効果
  useEffect(() => {
    const interval = setInterval(() => {
      setBreatheScale(prev => prev === 1 ? 1.02 : 1);
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  // 時間更新
  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  // 洗練されたボタンコンポーネント
  const TempoButton = ({ variant = 'primary', size = 'medium', children, onClick, disabled = false, className = '' }) => {
    const baseStyle = `
      font-weight: 600 transition-all duration-300 ease-out
      active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed
      flex items-center justify-center gap-2 relative overflow-hidden
    `;
    
    const variants = {
      primary: `
        text-white shadow-lg hover:shadow-xl
        ${size === 'large' ? 'py-4 px-8 text-lg rounded-2xl' : 'py-3 px-6 text-base rounded-xl'}
      `,
      secondary: `
        border-2 backdrop-blur-sm hover:backdrop-blur-md
        ${isDarkMode ? 'border-gray-600 text-gray-300 hover:border-gray-500' : 'border-gray-200 text-gray-700 hover:border-gray-300'}
        ${size === 'large' ? 'py-4 px-8 text-lg rounded-2xl' : 'py-3 px-6 text-base rounded-xl'}
      `,
      ghost: `
        text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800
        ${size === 'large' ? 'py-4 px-8 text-lg rounded-2xl' : 'py-3 px-6 text-base rounded-xl'}
      `,
      small: `
        py-2 px-4 text-sm rounded-lg font-semibold
        ${variant === 'primary' ? 'text-white shadow-md hover:shadow-lg' : ''}
      `
    };

    return (
      <button
        className={`${baseStyle} ${variants[variant]} ${className}`}
        onClick={onClick}
        disabled={disabled}
        style={variant === 'primary' ? { background: colors.primaryGradient } : {}}
      >
        {children}
      </button>
    );
  };

  // 洗練されたカードコンポーネント
  const TempoCard = ({ children, className = '', hover = true, padding = 'normal' }) => {
    return (
      <div 
        className={`
          backdrop-blur-sm border transition-all duration-300
          ${hover ? 'hover:shadow-lg hover:-translate-y-0.5' : ''}
          ${padding === 'large' ? 'p-6' : padding === 'small' ? 'p-3' : 'p-4'}
          ${className}
        `}
        style={{
          backgroundColor: colors.surface,
          borderColor: isDarkMode ? 'rgb(51, 65, 85)' : 'rgb(226, 232, 240)',
          boxShadow: isDarkMode 
            ? '0 4px 6px -1px rgba(0, 0, 0, 0.3), 0 2px 4px -1px rgba(0, 0, 0, 0.1)'
            : '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
          borderRadius: '1rem'
        }}
      >
        {children}
      </div>
    );
  };

  // 時間を美しく表現するコンポーネント
  const TimeIndicator = ({ remainingHours = 18 }) => {
    const progress = remainingHours / 24;
    const circumference = 2 * Math.PI * 16;
    const strokeDasharray = circumference;
    const strokeDashoffset = circumference * (1 - progress);
    
    return (
      <div className="relative w-12 h-12">
        <svg className="w-12 h-12 -rotate-90" viewBox="0 0 40 40">
          <circle
            cx="20"
            cy="20"
            r="16"
            fill="none"
            stroke={isDarkMode ? 'rgb(51, 65, 85)' : 'rgb(226, 232, 240)'}
            strokeWidth="2"
          />
          <circle
            cx="20"
            cy="20"
            r="16"
            fill="none"
            stroke={remainingHours < 3 ? colors.danger : remainingHours < 6 ? colors.warning : colors.success}
            strokeWidth="2"
            strokeDasharray={strokeDasharray}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            className="transition-all duration-1000 ease-out"
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span 
            className="text-xs font-semibold"
            style={{ color: remainingHours < 3 ? colors.danger : remainingHours < 6 ? colors.warning : colors.success }}
          >
            {remainingHours}h
          </span>
        </div>
      </div>
    );
  };

  // いまタブ - 現在の瞬間を美しく表現
  const NowTab = () => (
    <div className="p-6 space-y-6" style={{ backgroundColor: colors.bg }}>
      // ヒーローセクション - 現在の状態を詩的に表現 
      <TempoCard padding="large" className="text-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-10" style={{ background: colors.warmGradient }}></div>
        <div className="relative z-10">
          <div 
            className="text-8xl mb-4 transition-transform duration-2000 ease-in-out"
            style={{ transform: `scale(${breatheScale})` }}
          >
            😪
          </div>
          <h2 className="text-2xl font-bold mb-2" style={{ color: colors.textPrimary }}>
            疲れた...
          </h2>
          <p className="mb-4" style={{ color: colors.textSecondary }}>
            🏠 家で • {currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </p>
          <div className="mb-6">
            <p className="text-lg" style={{ color: colors.textPrimary }}>
              "なんか疲れた..."
            </p>
          </div>
          <TempoButton size="large" onClick={() => {}}>
            <span className="mr-2">✨</span>
            今の気持ちを更新
          </TempoButton>
        </div>
      </TempoCard>

      // 同じテンポの人々 - 温かい繋がりを表現 
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-xl font-bold flex items-center gap-2" style={{ color: colors.textPrimary }}>
            <span className="text-2xl">🌊</span>
            同じテンポの人
          </h3>
          <button className="text-sm font-semibold" style={{ color: colors.primary }}>
            もっと見る
          </button>
        </div>
        
        <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide">
          {[
            { name: 'みお', mood: '😪', activity: '残業疲れ', distance: '2km', online: true, avatar: 'み' },
            { name: 'けんと', mood: '🎮', activity: 'ゲーム中', distance: '5km', online: true, avatar: 'け' },
            { name: 'あかり', mood: '😪', activity: 'Netflix見てる', distance: '1km', online: false, avatar: 'あ' },
            { name: 'ゆうき', mood: '☕', activity: 'カフェなう', distance: '3km', online: true, avatar: 'ゆ' }
          ].map((user, i) => (
            <TempoCard key={i} className="min-w-[160px] text-center relative" hover={true}>
              {user.online && (
                <div className="absolute -top-1 -right-1 w-4 h-4 rounded-full border-2 border-white" style={{ backgroundColor: colors.online }}></div>
              )}
              <div 
                className="w-16 h-16 rounded-full mx-auto mb-3 flex items-center justify-center text-white font-bold text-lg shadow-lg"
                style={{ background: colors.primaryGradient }}
              >
                {user.avatar}
              </div>
              <h4 className="font-semibold mb-1" style={{ color: colors.textPrimary }}>
                {user.name}
              </h4>
              <div className="text-3xl mb-2">{user.mood}</div>
              <p className="text-xs mb-1" style={{ color: colors.textSecondary }}>
                {user.activity}
              </p>
              <p className="text-xs mb-4 opacity-75" style={{ color: colors.textTertiary }}>
                {user.distance}
              </p>
              <TempoButton 
                variant="small"
                onClick={() => setShowMatchAnimation(true)}
                className="w-full"
              >
                つながる
              </TempoButton>
            </TempoCard>
          ))}
        </div>
      </div>

      // バイラル機能 - 美しいシェア体験 
      <TempoCard className="relative overflow-hidden">
        <div className="absolute inset-0 opacity-5" style={{ background: colors.successGradient }}></div>
        <div className="relative flex items-center gap-4">
          <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ background: colors.successGradient }}>
            <span className="text-white text-xl">📸</span>
          </div>
          <div className="flex-1">
            <h4 className="font-semibold mb-1" style={{ color: colors.textPrimary }}>
              今日のテンポをシェア
            </h4>
            <p className="text-sm" style={{ color: colors.textSecondary }}>
              InstagramやTwitterで今の気持ちを共有
            </p>
          </div>
          <TempoButton variant="ghost">
            作成
          </TempoButton>
        </div>
      </TempoCard>

      // マッチングアニメーション - 喜びの瞬間を表現 
      {showMatchAnimation && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
          <div 
            className="max-w-sm mx-4 p-8 text-center rounded-3xl relative overflow-hidden"
            style={{ backgroundColor: colors.surface }}
          >
            <div className="absolute inset-0 opacity-10" style={{ background: colors.successGradient }}></div>
            <div className="relative z-10">
              <div className="text-6xl mb-4 animate-bounce">🎉</div>
              <h2 className="text-2xl font-bold mb-2" style={{ color: colors.textPrimary }}>
                テンポが合いました！
              </h2>
              <p className="mb-6" style={{ color: colors.textSecondary }}>
                みおさんと24時間つながることができます
              </p>
              <div className="flex gap-3">
                <TempoButton 
                  variant="secondary"
                  onClick={() => setShowMatchAnimation(false)}
                  className="flex-1"
                >
                  後で話す
                </TempoButton>
                <TempoButton 
                  onClick={() => {
                    setShowMatchAnimation(false);
                    setActiveTab(1);
                  }}
                  className="flex-1"
                >
                  チャット開始
                </TempoButton>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );

  // なかまタブ - 繋がりの温かさを表現
  const NakamaTab = () => (
    <div className="p-6 space-y-6" style={{ backgroundColor: colors.bg }}>
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold mb-2" style={{ color: colors.textPrimary }}>
          今日のなかま
        </h2>
        <p style={{ color: colors.textSecondary }}>
          24時間限定の特別な繋がり
        </p>
      </div>

      // アクティブな繋がり 
      <div className="space-y-4">
        <TempoCard className="relative">
          <div className="flex items-center gap-4 mb-4">
            <div 
              className="w-14 h-14 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg relative"
              style={{ background: colors.primaryGradient }}
            >
              み
              <div className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white" style={{ backgroundColor: colors.online }}></div>
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-lg" style={{ color: colors.textPrimary }}>
                みお
              </h3>
              <p className="flex items-center gap-2" style={{ color: colors.textSecondary }}>
                <span className="text-lg">😪</span>
                残業お疲れモード
              </p>
            </div>
            <TimeIndicator remainingHours={18} />
          </div>
          
          <div className="grid grid-cols-2 gap-3">
            <TempoButton variant="ghost" className="flex items-center justify-center gap-2">
              <span className="text-lg">⚡</span>
              応援する
            </TempoButton>
            <TempoButton>
              <span className="mr-2">💬</span>
              チャット
            </TempoButton>
          </div>
        </TempoCard>

        // 期限間近の繋がり 
        <TempoCard className="relative ring-2 ring-amber-500/30">
          <div className="flex items-center gap-4 mb-4">
            <div 
              className="w-14 h-14 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg"
              style={{ background: colors.warmGradient }}
            >
              け
            </div>
            <div className="flex-1">
              <h3 className="font-semibold text-lg" style={{ color: colors.textPrimary }}>
                けんと
              </h3>
              <p className="flex items-center gap-2" style={{ color: colors.textSecondary }}>
                <span className="text-lg">🎮</span>
                ゲーム集中タイム
              </p>
            </div>
            <TimeIndicator remainingHours={2} />
          </div>
          
          <div className="bg-gradient-to-r from-amber-500/10 to-orange-500/10 rounded-xl p-3 mb-3">
            <p className="text-sm font-medium text-center" style={{ color: colors.warning }}>
              もうすぐ24時間が終了します
            </p>
          </div>
          
          <div className="grid grid-cols-2 gap-3">
            <TempoButton 
              variant="secondary" 
              className="border-amber-500/50 text-amber-600 hover:bg-amber-500/10"
            >
              <span className="mr-2">⏰</span>
              延長する
            </TempoButton>
            <TempoButton>
              <span className="mr-2">💬</span>
              チャット
            </TempoButton>
          </div>
        </TempoCard>
      </div>

      // 今オンラインの人々 
      <div>
        <h3 className="text-lg font-semibold mb-4 flex items-center gap-2" style={{ color: colors.textPrimary }}>
          <span className="w-2 h-2 rounded-full animate-pulse" style={{ backgroundColor: colors.online }}></span>
          今オンライン
        </h3>
        <div className="flex gap-3 overflow-x-auto pb-2">
          {['あかり', 'ゆうき', 'さき', 'たけし', 'まい'].map((name, i) => (
            <div key={i} className="flex flex-col items-center min-w-[70px] group cursor-pointer">
              <div 
                className="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-sm shadow-lg relative transition-transform group-hover:scale-110"
                style={{ background: colors.successGradient }}
              >
                {name[0]}
                <div className="absolute -bottom-1 -right-1 w-3 h-3 rounded-full border-2 border-white" style={{ backgroundColor: colors.online }}></div>
              </div>
              <span className="text-xs mt-1 text-center" style={{ color: colors.textSecondary }}>
                {name}
              </span>
            </div>
          ))}
        </div>
      </div>

      // 思い出のシェア 
      <TempoCard className="text-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-5" style={{ background: colors.warmGradient }}></div>
        <div className="relative">
          <div className="text-4xl mb-3">✨</div>
          <h3 className="font-bold mb-2" style={{ color: colors.textPrimary }}>
            素敵な24時間でした
          </h3>
          <p className="mb-4" style={{ color: colors.textSecondary }}>
            みおさんとの思い出を記録しませんか？
          </p>
          <TempoButton className="bg-gradient-to-r from-pink-500 to-orange-500">
            <span className="mr-2">📱</span>
            思い出カードを作成
          </TempoButton>
        </div>
      </TempoCard>
    </div>
  );

  // じぶんタブ - 個性と成長を美しく表現
  const JibunTab = () => (
    <div className="p-6 space-y-6" style={{ backgroundColor: colors.bg }}>
      // プロフィールヘッダー 
      <TempoCard className="text-center relative overflow-hidden" padding="large">
        <div className="absolute inset-0 opacity-5" style={{ background: colors.primaryGradient }}></div>
        <div className="relative">
          <div 
            className="w-24 h-24 rounded-full mx-auto mb-4 flex items-center justify-center text-white font-bold text-2xl shadow-2xl"
            style={{ background: colors.primaryGradient }}
          >
            あ
          </div>
          <h2 className="text-2xl font-bold mb-2" style={{ color: colors.textPrimary }}>
            あなた
          </h2>
          <p style={{ color: colors.textSecondary }}>
            今を大切にする人
          </p>
        </div>
      </TempoCard>

      // 今週のテンポ - データを詩的に表現 
      <TempoCard>
        <h3 className="font-bold mb-4 flex items-center gap-2" style={{ color: colors.textPrimary }}>
          <span className="text-xl">🌊</span>
          今週のテンポ
        </h3>
        <div className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="text-2xl">😪</div>
            <div className="flex-1">
              <div className="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div 
                  className="h-full rounded-full transition-all duration-1000"
                  style={{ 
                    background: colors.primaryGradient,
                    width: '60%'
                  }}
                ></div>
              </div>
            </div>
            <span className="text-sm font-medium" style={{ color: colors.textSecondary }}>
              よく感じた気分
            </span>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-2xl">🏠</div>
            <div className="flex-1">
              <div className="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div 
                  className="h-full rounded-full transition-all duration-1000"
                  style={{ 
                    background: colors.warmGradient,
                    width: '80%'
                  }}
                ></div>
              </div>
            </div>
            <span className="text-sm font-medium" style={{ color: colors.textSecondary }}>
              よくいた場所
            </span>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-2xl">✨</div>
            <div className="flex-1">
              <div className="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div 
                  className="h-full rounded-full transition-all duration-1000"
                  style={{ 
                    background: colors.successGradient,
                    width: '45%'
                  }}
                ></div>
              </div>
            </div>
            <span className="text-sm font-medium" style={{ color: colors.textSecondary }}>
              つながった回数
            </span>
          </div>
        </div>
        <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
          <TempoButton variant="ghost" className="w-full">
            <span className="mr-2">📊</span>
            週間レポートをシェア
          </TempoButton>
        </div>
      </TempoCard>

      // バッジコレクション - 成就感を演出 
      <TempoCard>
        <h3 className="font-bold mb-4 flex items-center gap-2" style={{ color: colors.textPrimary }}>
          <span className="text-xl">🏆</span>
          コレクション
        </h3>
        <div className="grid grid-cols-4 gap-3">
          {[
            { emoji: '🌅', name: '朝型', earned: true, color: 'bg-orange-100 border-orange-200' },
            { emoji: '🤝', name: '社交家', earned: true, color: 'bg-blue-100 border-blue-200' },
            { emoji: '💬', name: '話し上手', earned: true, color: 'bg-green-100 border-green-200' },
            { emoji: '✨', name: '応援者', earned: false, color: 'bg-gray-100 border-gray-200' },
            { emoji: '🎯', name: '達人', earned: false, color: 'bg-gray-100 border-gray-200' },
            { emoji: '📱', name: 'シェア王', earned: true, color: 'bg-pink-100 border-pink-200' },
            { emoji: '🔥', name: '人気者', earned: false, color: 'bg-gray-100 border-gray-200' },
            { emoji: '🌟', name: '伝説', earned: false, color: 'bg-gray-100 border-gray-200' }
          ].map((badge, i) => (
            <div 
              key={i} 
              className={`
                text-center p-3 rounded-xl border transition-all duration-300 hover:scale-105
                ${badge.earned ? badge.color : 'opacity-40'}
              `}
            >
              <div className={`text-2xl mb-1 ${!badge.earned ? 'grayscale' : ''}`}>
                {badge.emoji}
              </div>
              <div className={`text-xs font-medium ${badge.earned ? 'text-gray-700' : 'text-gray-400'}`}>
                {badge.name}
              </div>
            </div>
          ))}
        </div>
      </TempoCard>

      // 友達招待 - バイラル促進 
      <TempoCard className="relative overflow-hidden ring-2 ring-blue-500/20">
        <div className="absolute inset-0 opacity-5" style={{ background: colors.primaryGradient }}></div>
        <div className="relative text-center">
          <div className="text-4xl mb-3">🎁</div>
          <h3 className="font-bold mb-2" style={{ color: colors.textPrimary }}>
            友達を招待しよう
          </h3>
          <p className="mb-4" style={{ color: colors.textSecondary }}>
            特別な人を招待して、一緒にTempoを楽しもう
          </p>
          <TempoButton size="large" className="w-full">
            <span className="mr-2">📨</span>
            招待リンクを送る
          </TempoButton>
          <p className="mt-2 text-xs" style={{ color: colors.textTertiary }}>
            今月あと <span className="font-bold" style={{ color: colors.primary }}>2回</span> 招待できます
          </p>
        </div>
      </TempoCard>

      // 設定メニュー - 洗練されたリスト 
      <div className="space-y-2">
        {[
          { icon: '🔔', label: '通知設定', description: 'プッシュ通知の管理' },
          { icon: '🌙', label: 'ダークモード', description: '目に優しい表示', toggle: true },
          { icon: '🔒', label: 'プライバシー', description: '公開設定の変更' },
          { icon: '⭐', label: 'レビューを書く', description: 'App Storeで評価', special: true }
        ].map((item, i) => (
          <TempoCard key={i} className="cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800" hover={false}>
            <div className="flex items-center gap-4">
              <div 
                className="w-10 h-10 rounded-full flex items-center justify-center"
                style={{ backgroundColor: item.special ? colors.warning + '20' : colors.primary + '20' }}
              >
                <span className="text-lg">{item.icon}</span>
              </div>
              <div className="flex-1">
                <h4 className="font-medium" style={{ color: colors.textPrimary }}>
                  {item.label}
                </h4>
                <p className="text-sm" style={{ color: colors.textSecondary }}>
                  {item.description}
                </p>
              </div>
              {item.toggle ? (
                <div 
                  className={`
                    w-12 h-6 rounded-full relative transition-all duration-300 cursor-pointer
                    ${isDarkMode ? 'bg-blue-500' : 'bg-gray-300'}
                  `}
                >
                  <div 
                    className={`
                      w-5 h-5 bg-white rounded-full absolute top-0.5 transition-transform duration-300
                      ${isDarkMode ? 'translate-x-6' : 'translate-x-0.5'}
                    `}
                  ></div>
                </div>
              ) : item.special ? (
                <div className="px-2 py-1 rounded-full text-xs font-bold" style={{ backgroundColor: colors.warning + '30', color: colors.warning }}>
                  特典
                </div>
              ) : (
                <span style={{ color: colors.textTertiary }}>→</span>
              )}
            </div>
          </TempoCard>
        ))}
      </div>
    </div>
  );

  const tabs = [
    { name: 'いま', component: NowTab, icon: '🌊' },
    { name: 'なかま', component: NakamaTab, icon: '💫' },
    { name: 'じぶん', component: JibunTab, icon: '✨' }
  ];

  return (
    <div 
      className="max-w-md mx-auto h-screen flex flex-col transition-all duration-500 overflow-hidden"
      style={{ backgroundColor: colors.bg }}
    >
      // 洗練されたヘッダー 
      <div 
        className="px-6 py-4 backdrop-blur-lg border-b relative"
        style={{ 
          backgroundColor: colors.surface + 'CC',
          borderColor: isDarkMode ? 'rgb(51, 65, 85)' : 'rgb(226, 232, 240)'
        }}
      >
        <div className="text-center">
          <h1 
            className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r"
            style={{ backgroundImage: colors.primaryGradient }}
          >
            Tempo
          </h1>
          <p className="text-sm mt-1" style={{ color: colors.textSecondary }}>
            今この瞬間を、誰かと
          </p>
        </div>
      </div>

      // メインコンテンツ 
      <div className="flex-1 overflow-y-auto">
        {tabs[activeTab].component()}
      </div>

      // 洗練されたボトムタブ 
      <div 
        className="px-6 py-3 backdrop-blur-lg border-t relative"
        style={{ 
          backgroundColor: colors.surface + 'CC',
          borderColor: isDarkMode ? 'rgb(51, 65, 85)' : 'rgb(226, 232, 240)'
        }}
      >
        <div className="flex">
          {tabs.map((tab, index) => (
            <button
              key={index}
              className={`
                flex-1 py-3 px-2 rounded-2xl mx-1 font-bold text-sm
                transition-all duration-300 ease-out
                flex flex-col items-center gap-1
                ${activeTab === index 
                  ? 'shadow-lg transform -translate-y-0.5' 
                  : 'hover:bg-gray-100 dark:hover:bg-gray-800'
                }
              `}
              onClick={() => setActiveTab(index)}
              style={activeTab === index ? {
                background: colors.primaryGradient,
                color: 'white'
              } : {
                color: colors.textSecondary
              }}
            >
              <span className="text-lg">{tab.icon}</span>
              <span>{tab.name}</span>
            </button>
          ))}
        </div>
      </div>

      // カスタムCSS for scrollbar hide 
      <style jsx>{`
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </div>
  );
};

export default TempoAppV5;
 */