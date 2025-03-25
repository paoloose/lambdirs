import lambdirsLogo from '/logo_480.png';

export function Header() {
  return (
    <header className='flex border-1 border-transparent'>
      <a href="/" target="_self" className='flex items-center gap-2'>
        <img className='h-8' src={lambdirsLogo} alt="Lambdirs Logo" />
        <span className='font-bold'>Lambdirs</span>
      </a>
    </header>
  );
}
